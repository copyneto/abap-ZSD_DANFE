*&---------------------------------------------------------------------*
*& Include          ZSDI_FILL_EXPORT
*&---------------------------------------------------------------------*
   TYPES ty_t_nfetx_fillexport TYPE TABLE OF j_1bnfftx .

   DATA: lv_msg      TYPE string,
         lv_desconto TYPE vbrp-kzwi4,
         lv_despesas TYPE vbrp-kzwi6,
         lv_total    TYPE vbrk-netwr,
         lt_msg      TYPE  TABLE OF string,
         lv_kzwi1    TYPE vbrp-kzwi1,
         lv_fob      TYPE vbrp-netwr,
         lv_kurrf    TYPE  string.

   DATA lt_text_tab TYPE TABLE OF string.

   CONSTANTS: lc_canal TYPE vbrk-vtweg        VALUE '13',
              lc_bi    TYPE j_1bnflin-reftyp  VALUE 'BI'.

   CONSTANTS: BEGIN OF lc_param_exp,
                modulo TYPE ztca_param_par-modulo VALUE 'SD',
                chave1 TYPE ztca_param_par-chave1 VALUE 'UNIDADE_EXPORTACAO',
              END OF lc_param_exp.

   DATA lt_especie TYPE RANGE OF j_1b_trans_vol_type.

   FIELD-SYMBOLS <fs_wnfdoc>           TYPE j_1bnfdoc.
   FIELD-SYMBOLS <fs_nfetx_fillexport> TYPE ty_t_nfetx_fillexport.

   ASSIGN ('(SAPLJ1BG)wnfftx[]') TO <fs_nfetx_fillexport>.

   DATA(lt_item) = it_nflin.
   SORT lt_item BY reftyp.
   CLEAR: lv_desconto, lv_despesas, lv_total.

   LOOP AT it_vbrp ASSIGNING FIELD-SYMBOL(<fs_sun>).
     lv_despesas = lv_despesas + <fs_sun>-kzwi6.
     lv_desconto = lv_desconto + <fs_sun>-kzwi4.
     lv_kzwi1    = lv_kzwi1    + <fs_sun>-kzwi1.

     IF <fs_sun>-spart = 05 AND is_header-nftype <> 'IN'.
       lv_fob = lv_fob + ( <fs_sun>-netwr / <fs_sun>-fkimg ).
     ENDIF.

   ENDLOOP.


   READ TABLE lt_item TRANSPORTING NO FIELDS WITH KEY reftyp = lc_bi BINARY SEARCH .

   IF sy-subrc = 0 AND is_vbrk-vtweg = lc_canal.

     READ TABLE it_vbrp ASSIGNING FIELD-SYMBOL(<fs_doc_fat>) INDEX 1.
     IF sy-subrc = 0.
       SELECT SINGLE zz1_ufemb_sdh, zz1_xloce_sdh,
                     zz1_espc_sdh, zz1_qtde_sdh
         FROM vbak
         INTO @DATA(ls_ordem_venda)
         WHERE vbeln EQ @<fs_doc_fat>-aubel.

       IF sy-subrc = 0.

         TRANSLATE ls_ordem_venda-zz1_ufemb_sdh TO UPPER CASE.
         TRANSLATE ls_ordem_venda-zz1_xloce_sdh TO UPPER CASE.

         es_header-ufembarq   = ls_ordem_venda-zz1_ufemb_sdh.
         es_header-xlocembarq = ls_ordem_venda-zz1_xloce_sdh.

         ASSIGN ('(SAPLJ1BG)WNFDOC') TO <fs_wnfdoc>.
         IF <fs_wnfdoc> IS ASSIGNED.

           <fs_wnfdoc>-foreignid = '999.999.999'.

           IF NOT ls_ordem_venda-zz1_qtde_sdh IS INITIAL.
             <fs_wnfdoc>-anzpk  = ls_ordem_venda-zz1_qtde_sdh.

             READ TABLE et_transvol ASSIGNING FIELD-SYMBOL(<fs_transvol>) INDEX 1.
             IF sy-subrc EQ 0.
               <fs_transvol>-esp  = ls_ordem_venda-zz1_espc_sdh.
               <fs_transvol>-qvol = ls_ordem_venda-zz1_qtde_sdh.

               CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
                 EXPORTING
                   input    = ls_ordem_venda-zz1_espc_sdh
                   language = sy-langu
                 IMPORTING
                   output   = ls_ordem_venda-zz1_espc_sdh.
               IF sy-subrc = 0.
                 DATA(lo_param1) = NEW zclca_tabela_parametros( ).
                 TRY.
                     lo_param1->m_get_range( EXPORTING iv_modulo = lc_param_exp-modulo
                                                       iv_chave1 = lc_param_exp-chave1
                                             IMPORTING et_range  = lt_especie ).
                   CATCH zcxca_tabela_parametros.
                 ENDTRY.
                 TRY.
                     DATA(lv_especie) = lt_especie[ low = ls_ordem_venda-zz1_espc_sdh ]-high.
                     <fs_transvol>-esp = lv_especie.
                   CATCH cx_sy_itab_line_not_found.
                     <fs_transvol>-esp = ls_ordem_venda-zz1_espc_sdh.
                 ENDTRY.
                 <fs_wnfdoc>-shpunt = ls_ordem_venda-zz1_espc_sdh.
               ENDIF.
             ENDIF.
           ENDIF.
         ENDIF.

*** Texto Dados de Exportção

         lv_desconto = abs( lv_desconto ).
         IF lv_kzwi1 IS NOT INITIAL.
           lv_msg = |{ TEXT-f36 } { is_vbrk-waerk }: { lv_kzwi1 },|.
         ENDIF.
         IF lv_desconto IS NOT INITIAL.
           lv_msg = |{ lv_msg } { TEXT-f37 } { is_vbrk-waerk }: { lv_desconto }, |.
           CONDENSE lv_msg.
           APPEND lv_msg TO lt_msg. CLEAR lv_msg.
         ELSEIF lv_msg IS NOT INITIAL.
           APPEND lv_msg TO lt_msg. CLEAR lv_msg.
         ENDIF.

         IF is_vbrk-netwr IS NOT INITIAL.
           IF is_vbrk-fkart(1) EQ 'Y'.
             lv_total = is_vbrk-netwr + lv_despesas - lv_desconto.
           ELSE.
             lv_total = is_vbrk-netwr.
           ENDIF.
           lv_msg = |{ TEXT-f38 } { is_vbrk-waerk }: { lv_total },|.
         ENDIF.
         IF  lv_fob IS NOT INITIAL.
           lv_msg = |{ lv_msg } { TEXT-f46 } { is_vbrk-waerk }: { lv_fob },|.
           CONDENSE lv_msg.
           APPEND lv_msg TO lt_msg. CLEAR lv_msg.
         ELSEIF lv_msg IS NOT INITIAL.
           APPEND lv_msg TO lt_msg. CLEAR lv_msg.
         ENDIF.

         CLEAR lv_kurrf.
         lv_kurrf = is_vbrk-kurrf.
         CONDENSE lv_kurrf.
         REPLACE ALL OCCURRENCES OF '.' IN lv_kurrf WITH ','.
         lv_msg = |{ TEXT-f44 }: { is_vbrk-inco1 }, { TEXT-f39 }: { lv_kurrf },|.
         APPEND lv_msg TO lt_msg. CLEAR lv_msg.
         lv_msg = |{ TEXT-f40 }: { ls_ordem_venda-zz1_ufemb_sdh },{ TEXT-f41 }: { ls_ordem_venda-zz1_xloce_sdh }|.
         APPEND lv_msg TO lt_msg. CLEAR lv_msg.

         LOOP AT lt_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).

           DATA(lt_nfetx) = <fs_nfetx_fillexport>.

           SORT lt_nfetx BY seqnum DESCENDING.

           DATA(lv_seq) = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
           DATA(lv_linnum) = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

           ADD 1 TO lv_seq.

           IF <fs_nfetx_fillexport> IS ASSIGNED.
             APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_msg> ) TO <fs_nfetx_fillexport>.
             es_header-infcpl = |{ es_header-infcpl }  { <fs_msg> }|.
           ENDIF.

           CLEAR: lv_msg.
         ENDLOOP.

*** Texto Dados de Exportção

       ENDIF.
     ENDIF.

   ENDIF.
