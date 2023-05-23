*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_NUMERO_PEDIDO
*&---------------------------------------------------------------------*
 CONSTANTS: lc_num_pedido TYPE ztca_param_par-chave2 VALUE 'NUM_PEDIDO',
            lc_md         TYPE char4                 VALUE 'MD',
            lc_li         TYPE char4                 VALUE 'LI',
            lc_bsart_zdf  TYPE bsart                 VALUE 'ZDF',
            lc_bsart_ub   TYPE bsart                 VALUE 'UB'.

 DATA: lr_tp_fat TYPE RANGE OF vbrk-fkart.

 DATA(lt_nflin) = it_nflin.
 SORT lt_nflin BY reftyp.

 READ TABLE lt_nflin ASSIGNING FIELD-SYMBOL(<fs_lin>)
                                   WITH KEY reftyp = lc_ref
                                   BINARY SEARCH.
 IF sy-subrc EQ 0.

   DATA(lo_num_pedido) = NEW zclca_tabela_parametros( ).

   TRY.
       lo_num_pedido->m_get_range( EXPORTING iv_modulo = lc_modulo
                                             iv_chave1 = lc_nfe
                                             iv_chave2 = lc_num_pedido
                                   IMPORTING et_range  = lr_tp_fat ).
     CATCH zcxca_tabela_parametros.
   ENDTRY.

   IF lr_tp_fat        IS NOT INITIAL
  AND is_vbrk-fkart    IN lr_tp_fat
  AND is_vbrk-bstnk_vf IS NOT INITIAL.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
     SEARCH cs_header-infcpl FOR TEXT-f49.
     IF sy-subrc NE 0.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim
       SEARCH cs_header-infcpl FOR TEXT-f54.
       IF sy-subrc NE 0.
         lv_texto = |{ TEXT-f54 }: { is_vbrk-bstnk_vf }|.
       ENDIF.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
     ENDIF.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim

   ELSE.

     IF NOT <fs_lin>-xped IS INITIAL.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
       SEARCH cs_header-infcpl FOR TEXT-f49.
       IF sy-subrc NE 0.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim
         SEARCH cs_header-infcpl FOR TEXT-f54.
         IF sy-subrc NE 0.
           lv_texto = |{ TEXT-f54 }: { <fs_lin>-xped }|.
         ENDIF.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
       ENDIF.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim
     ENDIF.

   ENDIF.

 ELSE.
*      IF sy-uname = 'DLIMA' OR sy-uname = 'CRODRIGUES'.

   LOOP AT lt_nflin INTO DATA(ls_nflin_x) WHERE reftyp = lc_md OR reftyp = lc_li.

     TRY.

         DATA(lv_xped) = ct_itens_adicional[ itmnum = ls_nflin_x-itmnum ]-xped.

         IF lv_xped IS NOT INITIAL.

           SELECT COUNT( * )
             FROM i_purchasingdocument
            WHERE purchasingdocument = @lv_xped
              AND purchasingdocumenttype = @lc_bsart_zdf
               OR purchasingdocumenttype = @lc_bsart_ub.

           CHECK sy-subrc NE 0.

           lv_texto = |{ TEXT-f54 }: { lv_xped }|.

           EXIT.

         ENDIF.

       CATCH cx_sy_itab_line_not_found INTO DATA(lv_error).
     ENDTRY.

   ENDLOOP.
 ENDIF.
*    ENDIF.

 IF lv_texto IS NOT INITIAL.

   CONDENSE: lv_texto.

   SEARCH cs_header-infcpl FOR lv_texto.
   IF sy-subrc NE 0.
     cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
     CONDENSE cs_header-infcpl.
   ENDIF.

   CHECK <fs_nfetx_tab> IS ASSIGNED.

   lt_nfetx = <fs_nfetx_tab>.

   SORT lt_nfetx BY seqnum DESCENDING.

   lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
   lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

   ADD 1 TO lv_seq.
   IF <fs_nfetx_tab> IS ASSIGNED.
     APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
   ENDIF.

   CLEAR: lv_texto.

 ENDIF.
