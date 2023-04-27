*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_INF_PAUTA_INFCPL
*&---------------------------------------------------------------------*

   CONSTANTS: lc_zvpc TYPE char4  VALUE 'ZVPC',
              lc_ref  TYPE char4  VALUE 'BI'.

   DATA: lv_valor_pauta  TYPE vbak-netwr.

   READ TABLE it_nflin TRANSPORTING NO FIELDS WITH KEY reftyp = lc_ref BINARY SEARCH.
   IF sy-subrc EQ 0.

     READ TABLE it_vbrp ASSIGNING <fs_vbrp> INDEX 1.
     IF sy-subrc EQ 0.

       CLEAR:lv_knumv.
       SELECT SINGLE knumv
         FROM vbak
         INTO @lv_knumv
         WHERE vbeln EQ @<fs_vbrp>-aubel.

       IF sy-subrc EQ 0.

         SELECT prcd_elements~kbetr
         FROM prcd_elements
         INTO @DATA(lv_pauta)
         UP TO 1 ROWS
         WHERE knumv = @lv_knumv
           AND kposn = @<fs_vbrp>-aupos
           AND kschl = @lc_zvpc.
         ENDSELECT.

         IF lv_pauta IS NOT INITIAL.

           lv_valor_pauta = lv_pauta.

           lt_nfetx = <fs_nfetx_tab>.

           SORT lt_nfetx BY seqnum DESCENDING.

           lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
           lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

           ADD 1 TO lv_seq.
           lv_texto = |{ TEXT-f47 }: { lv_valor_pauta } { TEXT-f48 }: { is_vbrk-fkdat+6(2) }.{ is_vbrk-fkdat+4(2) }.{ is_vbrk-fkdat(4) }.|.
           IF <fs_nfetx_tab> IS ASSIGNED.
             APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
             SEARCH cs_header-infcpl FOR lv_texto.
             IF sy-subrc NE 0.
               cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
             ENDIF.
           ENDIF.

           CLEAR: lv_texto.
         ENDIF.

       ENDIF.

     ENDIF.

   ENDIF.
