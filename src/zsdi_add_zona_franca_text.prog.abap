*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_ZONA_FRANCA_TEXT
*&---------------------------------------------------------------------*
   DATA(lt_nfstx) = it_nfstx.
   SORT lt_nfstx BY taxtyp.
   READ TABLE lt_nfstx TRANSPORTING NO FIELDS WITH KEY taxtyp = lc_taxtyp2 BINARY SEARCH.

   IF sy-subrc = 0.

     LOOP AT it_nfstx ASSIGNING FIELD-SYMBOL(<fs_nfstx>).

       IF <fs_nfstx>-taxtyp = lc_taxtyp2.
         IF <fs_nfstx>-taxval < 0.
           lv_val2 = <fs_nfstx>-taxval * -1.
         ELSE.
           lv_val2 = <fs_nfstx>-taxval.
         ENDIF.

         lv_val = lv_val + lv_val2.
       ENDIF.

     ENDLOOP.

     lv_taxval = lv_val.
     REPLACE ALL OCCURRENCES OF '.' IN lv_taxval WITH ','.
     CONDENSE lv_taxval.
     lv_texto = |{ TEXT-f01 }: { lv_taxval }|.

*    Alterar Suframa Transferência - gap 524
     IF is_header-partyp = lc_partyp_b AND
        it_nflin[ 1 ]-itmtyp = '02'.

       IF is_header-isuf IS INITIAL.

         DATA(lv_parid) = VALUE #( it_partner[ 1 ]-parid OPTIONAL ).
         DATA(lv_parid_c) = VALUE #( it_partner[ partyp = |C| ]-parid OPTIONAL ).

         IF lv_parid IS NOT INITIAL.

           SELECT SINGLE suframa FROM kna1
             WHERE kunnr = @lv_parid
              INTO @cs_header-isuf.
         ENDIF.

         IF lv_parid_c IS NOT INITIAL AND cs_header-isuf IS INITIAL.

           SELECT SINGLE suframa FROM kna1
             WHERE kunnr = @lv_parid_c
              INTO @cs_header-isuf.
         ENDIF.

         IF cs_header-isuf IS NOT INITIAL. "sy-subrc EQ 0.

           ASSIGN ('(SAPLJ1BG)WNFFTX[]') TO <fs_nfetx_tab>.
           IF NOT <fs_nfetx_tab> IS ASSIGNED.
             ASSIGN ('(SAPLJ1BF)WA_NF_FTX[]') TO <fs_nfetx_tab>.
           ENDIF.

           IF <fs_nfetx_tab> IS ASSIGNED.

             lt_nfetx = <fs_nfetx_tab>.

             LOOP AT lt_nfetx ASSIGNING FIELD-SYMBOL(<fs_nfe>).
               IF sy-tabix EQ 1.
                 cs_header-infcpl = <fs_nfe>-message.
               ELSE.
                 cs_header-infcpl = |{ cs_header-infcpl }| && |{ ' - ' }| && |{ <fs_nfe>-message }|.
               ENDIF.
             ENDLOOP.

             DO 2 TIMES.

               SORT lt_nfetx BY seqnum ASCENDING.

               CASE sy-index.
                 WHEN 1.

                   APPEND VALUE j_1bnfftx( seqnum  = VALUE #( lt_nfetx[ lines( lt_nfetx ) ]-seqnum OPTIONAL ) + 01
                                           linnum  = 01
                                           message = lv_texto ) TO <fs_nfetx_tab>.

                   cs_header-infcpl = |{ cs_header-infcpl }| && |{ ' - ' }| && |{ lv_texto }|.

                 WHEN 2.

                   APPEND VALUE j_1bnfftx( seqnum  = VALUE #( lt_nfetx[ lines( lt_nfetx ) ]-seqnum OPTIONAL ) + 02
                                           linnum  = 01
                                           message = |{ TEXT-f03 }: { cs_header-isuf }| ) TO <fs_nfetx_tab>.

                   cs_header-infcpl = |{ cs_header-infcpl }| && |{ ' - ' }| && |{ TEXT-f03 }: { cs_header-isuf }|.

               ENDCASE.

               CLEAR: lv_texto.

             ENDDO.

           ENDIF.

           CLEAR: lv_texto.

         ENDIF.

       ENDIF.
     ELSE.

       IF <fs_nfetx_tab> IS ASSIGNED.
         lt_nfetx = <fs_nfetx_tab>.

         SORT lt_nfetx BY seqnum DESCENDING.

         lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
         lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
         ADD 1 TO lv_seq.

         APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
         cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
       ENDIF.

       CLEAR: lv_texto.

       IF  lv_motdesicms IS NOT INITIAL.

         DATA lt_descricao TYPE TABLE OF  dd07v.
         CALL FUNCTION 'GET_DOMAIN_VALUES'
           EXPORTING
             domname         = 'J_1B_ICMS_EXEM_REASON'
           TABLES
             values_tab      = lt_descricao
           EXCEPTIONS
             no_values_found = 1
             OTHERS          = 2.

         IF sy-subrc = 0.
           SORT lt_descricao BY ddlanguage domvalue_l.
           READ TABLE  lt_descricao ASSIGNING FIELD-SYMBOL(<fs_descricao>) WITH KEY ddlanguage = sy-langu
                                                                                    domvalue_l = lv_motdesicms
                                                                           BINARY SEARCH.
           IF sy-subrc = 0.
             lv_texto = |{ TEXT-f02 }: { lv_motdesicms } { <fs_descricao>-ddtext }|.
           ENDIF.
         ENDIF.

       ENDIF.
     ENDIF.

     IF is_header-isuf IS NOT INITIAL.

       IF lv_texto IS NOT INITIAL.
         lv_texto = |{ lv_texto }/{ TEXT-f03 }: { is_header-isuf }|.
       ELSE.
         lv_texto = |{ TEXT-f03 }: { is_header-isuf }|.
       ENDIF.

       IF <fs_nfetx_tab> IS ASSIGNED.

         lt_nfetx = <fs_nfetx_tab>.

         SORT lt_nfetx BY seqnum DESCENDING.

         lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
         lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
         ADD 1 TO lv_seq.

         APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.

         cs_header-infcpl = |{ cs_header-infcpl }| && |{ ' - ' }| && |{ lv_texto }|.
       ENDIF.

       CLEAR: lv_texto.
     ENDIF.

   ELSE.

     IF NOT cs_header-isuf IS INITIAL.

       IF <fs_nfetx_tab> IS ASSIGNED.

         lt_nfetx = <fs_nfetx_tab>.
         SORT lt_nfetx BY seqnum DESCENDING.
         lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
         lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
         ADD 1 TO lv_seq.
         APPEND VALUE j_1bnfftx( seqnum = lv_seq
                                 linnum = lv_linnum
                                 message = |{ TEXT-f03 }: { cs_header-isuf }| ) TO <fs_nfetx_tab>.

         cs_header-infcpl = |{ cs_header-infcpl }| && |{ ' - ' }| && |{ TEXT-f03 }: { cs_header-isuf }|.

       ENDIF.

     ENDIF.

   ENDIF.
