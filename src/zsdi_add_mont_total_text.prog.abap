*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_MONT_TOTAL_TEXT
*&---------------------------------------------------------------------*
   IF lv_mont_total IS NOT INITIAL.

     IF <fs_nfetx_tab> IS ASSIGNED.
       lt_nfetx = <fs_nfetx_tab>.

       SORT lt_nfetx BY seqnum DESCENDING.

       lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
       lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
       ADD 1 TO lv_seq.
       lv_texto = |{ lv_texto } { TEXT-f20 }: { lv_mont_total }|.
       APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
       SEARCH cs_header-infcpl FOR lv_texto.
       IF sy-subrc NE 0.
         cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
       ENDIF.

     ENDIF.


     CLEAR: lv_texto,lv_mont_total.
   ENDIF.
