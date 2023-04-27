*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_CEST_EXT_IPI
*&---------------------------------------------------------------------*
     DATA: lv_cest_mask TYPE j_1bnflin-cest,
           lv_rate      TYPE i,
           lv_vicms     TYPE f,
           lv_vicmsop   TYPE f,
           lv_vicmsdif1 TYPE f,
           lv_linhas    TYPE char950.

     DATA lt_linhas TYPE TABLE OF j_1bmessag.


     CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
       EXPORTING
         input  = <fs_nflin>-matnr
       IMPORTING
         output = lv_matnr.

     IF lv_matnr IS NOT INITIAL.

       " calculo para montante: vicmsdif - inicio

       IF <fs_nflin>-reftyp = gc_fat.

         READ TABLE lt_vbrp_aux ASSIGNING FIELD-SYMBOL(<fs_vbrp>) WITH KEY posnr = <fs_nflin>-refitm
                                                                  BINARY SEARCH.

         IF sy-subrc = 0.

           READ TABLE lt_itens_add ASSIGNING FIELD-SYMBOL(<fs_item_adicional>) WITH KEY itmnum = <fs_nflin>-itmnum
                                                                               BINARY SEARCH.

           IF sy-subrc = 0.

             SELECT SINGLE knumv FROM vbak INTO @DATA(lv_knumv) WHERE vbeln = @<fs_vbrp>-aubel.

             IF lv_knumv IS NOT INITIAL.
               SELECT prcd_elements~kbetr
                 FROM prcd_elements
                 INTO @DATA(lv_kbetr)
                 UP TO 1 ROWS
                 WHERE knumv = @lv_knumv
                   AND kposn = @<fs_vbrp>-aupos
                   AND kschl = @lc_kschl.
               ENDSELECT.
             ENDIF.

             READ TABLE lt_wnfstx_tab ASSIGNING FIELD-SYMBOL(<fs_wnfstx>) WITH KEY docnum = <fs_nflin>-docnum
                                                                                   itmnum = <fs_nflin>-itmnum
                                                                                   taxtyp = lc_taxtyp BINARY SEARCH.
             IF sy-subrc = 0.
               lv_kzwi6_aux  = lv_kbetr.
               lv_novokzwi6  = 1 - ( lv_kzwi6_aux / 100 ).
               lv_vicmsdif1  = ( <fs_wnfstx>-taxval / lv_novokzwi6  ) * lv_kzwi6_aux.

               lv_vicmsdif1 = lv_vicmsdif1 / 100.

               IF  <fs_nflin>-taxsit EQ 'B'.
                 DATA(lv_rate_i) = <fs_wnfstx>-rate.
                 IF NOT <fs_wnfstx>-base IS INITIAL.
                   lv_rate = ( ( lv_vicmsdif1 + <fs_wnfstx>-taxval ) / <fs_wnfstx>-base ) * 100.
                   <fs_wnfstx>-rate = lv_rate.


                   lv_vicmsop = <fs_wnfstx>-rate * <fs_wnfstx>-base / 100.
                   lv_vicms = <fs_wnfstx>-base * lv_rate_i / 100.
                   lv_vicmsdif1 = lv_vicmsop - lv_vicms.
                   lv_vicmsdif = lv_vicmsdif1.
                 ENDIF.
               ELSE.
                 lv_vicmsdif = lv_vicmsdif1.
               ENDIF.

             ENDIF.

           ENDIF.

         ENDIF.

       ENDIF.

       " calculo para montante: vicmsdif - fim
       READ TABLE lt_itens_add ASSIGNING <fs_item_adicional> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
       IF sy-subrc EQ 0.
         IF <fs_item_adicional>-cest IS NOT INITIAL.
           DATA(lv_cest) = abap_true.
           lv_linhas = |{ 'ITEM' }: { lv_matnr }|.
           CALL FUNCTION 'CONVERSION_EXIT_CCEST_OUTPUT'
             EXPORTING
               input  = <fs_item_adicional>-cest   " CEST in internal format
             IMPORTING
               output = lv_cest_mask.     " CEST in screen format

           lv_linhas = |{ lv_linhas } { 'CEST' }: { lv_cest_mask }|.
         ENDIF.
       ENDIF.
       IF <fs_nflin>-nbm+11(2) IS NOT INITIAL.
         IF lv_cest IS INITIAL.
           lv_linhas = |{ 'ITEM' }: { lv_matnr }|.
         ENDIF.
         lv_linhas = |{ lv_linhas } { 'EXTIPI' }: { <fs_nflin>-nbm+11(2) }|.
       ENDIF.
       CLEAR lv_cest.
       IF <fs_nflin>-taxsit NE '1'.
         IF lv_vicmsdif IS NOT INITIAL.
           lv_linhas = |{ lv_linhas } { 'ITEM' }: { lv_matnr } { TEXT-f17 }: { lv_vicmsdif }|.
           lv_mont_total = lv_mont_total + lv_vicmsdif.
         ENDIF.
       ENDIF.

       ASSIGN ('(SAPLJ1BG)WNFFTX[]') TO <fs_nfetx_tab>.
       IF NOT <fs_nfetx_tab> IS ASSIGNED.
         ASSIGN ('(SAPLJ1BF)WA_NF_FTX[]') TO <fs_nfetx_tab>.
       ENDIF.

       IF <fs_nfetx_tab> IS ASSIGNED.
         lt_nfetx = <fs_nfetx_tab>.

         SORT lt_nfetx BY seqnum DESCENDING.

         FIND lv_linhas IN TABLE <fs_nfetx_tab>.
         IF sy-subrc NE 0.

           DATA(lv_skip1) = abap_false.

           REFRESH lt_linhas.
           CALL FUNCTION 'RKD_WORD_WRAP'
             EXPORTING
               textline            = lv_linhas
               outputlen           = 72
             TABLES
               out_lines           = lt_linhas
             EXCEPTIONS
               outputlen_too_large = 1
               OTHERS              = 2.

           lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
           lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
           LOOP AT lt_linhas ASSIGNING FIELD-SYMBOL(<fs_linhas>).
             ADD 1 TO lv_seq.
             IF <fs_nfetx_tab> IS ASSIGNED.
               APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_linhas> ) TO <fs_nfetx_tab>.
             ENDIF.
           ENDLOOP.
           SEARCH cs_header-infcpl FOR lv_linhas.
         ELSE.
           lv_skip1 = abap_true.
         ENDIF.

       ENDIF.

       FIND lv_linhas IN cs_header-infcpl.
       IF sy-subrc NE 0 AND lv_skip1 = abap_false.
         cs_header-infcpl = |{ cs_header-infcpl }  { lv_linhas }|.
       ENDIF.

       CLEAR: lv_texto, lv_linhas, lv_vicmsdif.
     ENDIF.

     CONDENSE cs_header-infcpl.
