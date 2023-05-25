*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_CLIENT_TEXT
*&---------------------------------------------------------------------*
   IF is_header-partyp = lc_partyp .

     TRY.
* LSCHEPP - SD - 8000007263 - GAP 47 erro no XML cadastro do cliente - 12.05.2023 Início
*         DATA(lv_name1) = it_partner[ parid = is_header-parid ]-name1.
         IF is_header-nftype EQ 'IM'. "Cenários E-commerce
           DATA(lv_name1) = it_partner[ parvw = 'AG' ]-name1.
         ELSE.
* LSCHEPP - SD - 8000007742 - DADOS GERAIS NF-NOME FANTASIA CLIENTE - 23.05.2023 Início
*           lv_name1 = it_partner[ parid = is_header-parid ]-name1.
           SELECT SINGLE bu_sort1
             FROM but000
             INTO @lv_name1
             WHERE partner EQ @is_header-parid.
* LSCHEPP - SD - 8000007742 - DADOS GERAIS NF-NOME FANTASIA CLIENTE - 23.05.2023 Fim
         ENDIF.
* LSCHEPP - SD - 8000007263 - GAP 47 erro no XML cadastro do cliente - 12.05.2023 Fim
       CATCH cx_sy_itab_line_not_found.
         SELECT SINGLE name1
           INTO @lv_name1
           FROM kna1
          WHERE kunnr = @is_header-parid.
     ENDTRY.

     IF sy-subrc IS INITIAL.

       IF <fs_nfetx_tab> IS ASSIGNED.

         DATA(lv_text_cli) = CONV char200( |{ TEXT-f14 } { is_header-parid } - { lv_name1 }| ).
         SEARCH cs_header-infcpl FOR lv_text_cli.
         IF sy-subrc NE 0.
           DATA(lt_nfetx) = <fs_nfetx_tab>.

           SORT lt_nfetx BY seqnum DESCENDING.

           DATA(lv_seq) = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
           DATA(lv_linnum) = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

           ADD 1 TO lv_seq.

           APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = |{ TEXT-f14 } { is_header-parid } - { lv_name1 }| ) TO <fs_nfetx_tab>.

           cs_header-infcpl = |{ cs_header-infcpl }  { lv_text_cli }|.

         ENDIF.
       ENDIF.

     ENDIF.
   ENDIF.
