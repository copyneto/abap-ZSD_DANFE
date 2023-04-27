*&---------------------------------------------------------------------*
*& Include          ZSDI_DEVOLUCAO_FORNEC_XML
*&---------------------------------------------------------------------*
*IT_DOC	TYPE J_1BNFDOC
*IT_LIN	TYPE J_1BNFLIN OPTIONAL
*CH_EXTENSION1  TYPE J1B_NF_XML_EXTENSION1_TAB
*CH_EXTENSION2  TYPE J1B_NF_XML_EXTENSION2_TAB

CONSTANTS: BEGIN OF lc_param,
             modulo TYPE ztca_param_par-modulo VALUE 'SD',
             chave1 TYPE ztca_param_par-chave1 VALUE 'ADM DEVOLUÇÃO',
             chave2 TYPE ztca_param_par-chave2 VALUE 'MOTIVO',
           END OF lc_param.

CONSTANTS:
  gc_modulo_mm  TYPE ze_param_modulo VALUE 'MM',
  gc_chave1_dev	TYPE ze_param_chave  VALUE 'DEVOLUCAO_COMPRAS',
  gc_chave2_out	TYPE ze_param_chave      VALUE 'OUTRAS_DESPESAS',
  gc_chave3_st  TYPE ze_param_chave_3    VALUE 'ST'.

TYPES: BEGIN OF ty_sum_valor,
         itmnum TYPE j_1bitmnum,
         voutro TYPE j_1bnfe_voutro,
       END OF ty_sum_valor.

DATA: lt_sum_valor TYPE TABLE OF ty_sum_valor,
      ls_sum_valor TYPE ty_sum_valor,
      lv_voutro    TYPE j_1bnfe_voutro.

DATA lt_augru TYPE RANGE OF augru.


IF it_doc-doctyp = '6'
  AND it_doc-direct = '2'
  AND it_doc-nfe    = abap_true.

  FIELD-SYMBOLS: <fs_wk_header1>   TYPE j_1bnfdoc,
                 <fs_xmli1>        TYPE j1b_nf_xml_item,
                 <fs_lt_item_tax1> TYPE ty_j_1bnfstx,
                 <fs_xmlh1>        TYPE j1b_nf_xml_header,
                 <fs_xmli_tab1>    TYPE  j1b_nf_xml_item_tab,
                 <fs_h1_voutro>    TYPE  j_1bnfe_voutro.

  ASSIGN ('(SAPLJ_1B_NFE)WK_HEADER')     TO <fs_wk_header1>.
  ASSIGN ('(SAPLJ_1B_NFE)XMLI')          TO <fs_xmli1>.
  ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM_TAX[]') TO <fs_lt_item_tax1>.
  ASSIGN ('(SAPLJ_1B_NFE)XMLH') TO <fs_xmlh1>.
  ASSIGN ('(SAPLJ_1B_NFE)XMLI_TAB') TO <fs_xmli_tab1>.
  ASSIGN ('(SAPLJ_1B_NFE)GV_H1_VOUTRO') TO <fs_h1_voutro>.

  IF <fs_wk_header1> IS ASSIGNED AND
    <fs_xmli1> IS ASSIGNED AND
    <fs_lt_item_tax1> IS ASSIGNED.

    SELECT sign, opt, low, high
      FROM ztca_param_val
      WHERE modulo = @gc_modulo_mm
        AND chave1 = @gc_chave1_dev
        AND chave2 = @gc_chave2_out
        AND chave3 = @gc_chave3_st
      INTO TABLE @DATA(lt_taxtyp_st).

    IF lt_taxtyp_st IS NOT INITIAL.
      IF <fs_h1_voutro> IS INITIAL.
        LOOP AT <fs_lt_item_tax1> ASSIGNING FIELD-SYMBOL(<fs_item_tax1>).
          CHECK <fs_item_tax1>-taxtyp IN lt_taxtyp_st.
          CHECK <fs_item_tax1>-taxval NE 0 AND <fs_item_tax1>-othbas NE 0.
          <fs_h1_voutro> = <fs_h1_voutro> + <fs_item_tax1>-taxval.
        ENDLOOP.
      ENDIF.
      CLEAR: <fs_xmlh1>-s1_vst, <fs_xmlh1>-s1_vbcst.
      <fs_xmlh1>-s1_voutro = <fs_h1_voutro>.

      IF <fs_xmli1>-h1_voutro IS INITIAL.
        CLEAR <fs_xmli1>-p_mvast.
        LOOP AT <fs_lt_item_tax1> ASSIGNING <fs_item_tax1>.
          CHECK <fs_item_tax1>-itmnum =  <fs_xmli1>-itmnum.
          CHECK <fs_item_tax1>-taxtyp IN lt_taxtyp_st.
          CHECK <fs_item_tax1>-taxval NE 0 AND <fs_item_tax1>-othbas NE 0.
          <fs_xmli1>-h1_voutro = <fs_xmli1>-h1_voutro + <fs_item_tax1>-taxval.
          CLEAR: <fs_item_tax1>-taxval, <fs_item_tax1>-basered1, <fs_item_tax1>-rate.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDIF.

  UNASSIGN: <fs_wk_header1>,
            <fs_xmli1>,
            <fs_lt_item_tax1>,
            <fs_xmlh1>.

ELSEIF it_doc-doctyp = '6' AND
       it_doc-direct = '1' AND
       it_doc-regio  = 'PR' AND
       it_doc-nfe    = abap_true.

  DATA(lo_param1) = NEW zclca_tabela_parametros( ).

  TRY.
      lo_param1->m_get_range( EXPORTING iv_modulo = lc_param-modulo
                                        iv_chave1 = lc_param-chave1
                                        iv_chave2 = lc_param-chave2
                              IMPORTING et_range  = lt_augru ).

      ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM[]') TO <fs_item>.
      IF <fs_item> IS ASSIGNED.
        READ TABLE <fs_item> ASSIGNING FIELD-SYMBOL(<fs_nflin>) INDEX 1.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = CONV vbeln_vf( <fs_nflin>-refkey ).
          SELECT SINGLE augru_auft
            FROM vbrp
            INTO @DATA(lv_augru)
            WHERE vbeln = @lv_vbeln.
          IF sy-subrc EQ 0.
            IF lv_augru IN lt_augru.
              ASSIGN ('(SAPLJ_1B_NFE)XMLH') TO <fs_xmlh>.
              IF <fs_xmlh> IS ASSIGNED.
                <fs_xmlh>-finnfe = '3'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    CATCH zcxca_tabela_parametros.
  ENDTRY.

ENDIF.
