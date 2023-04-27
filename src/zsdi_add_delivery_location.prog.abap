*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_DELIVERY_LOCATION
*&---------------------------------------------------------------------*
LOOP AT it_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

  IF <fs_partner>-partner_role EQ '0'.
    lv_msg = |{ TEXT-f04 }: { <fs_partner>-name1 }: { <fs_partner>-stras }, { <fs_partner>-ort02 }, { <fs_partner>-ort01 }{ ',' }{ <fs_partner>-regio }|.

    CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
      EXPORTING
        text                = lv_msg
        flag_no_line_breaks = 'X'
        line_length         = '55'
        langu               = sy-langu
      TABLES
        text_tab            = lt_text_tab.

    IF <fs_nfetx_tab> IS ASSIGNED.
      lt_nfetx = <fs_nfetx_tab>.
    ENDIF.

    SORT lt_nfetx BY seqnum DESCENDING.

    CLEAR lv_linnum.
    LOOP AT lt_text_tab ASSIGNING FIELD-SYMBOL(<fs_msg>).

      lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
*      lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

      ADD 1 TO lv_seq.

      lv_linnum = lv_linnum + 1.

      IF <fs_nfetx_tab> IS ASSIGNED.
        APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_msg> ) TO <fs_nfetx_tab>.
      ENDIF.

      cs_header-infcpl = |{ cs_header-infcpl }  { <fs_msg> }|.

      CLEAR: lv_msg.
    ENDLOOP.



  ELSEIF <fs_partner>-partner_role EQ '1'.

    lv_msg = |{ TEXT-f05 }: { <fs_partner>-stras }, { <fs_partner>-ort02 }, { <fs_partner>-ort01 } { ',' } { <fs_partner>-regio }|.

    CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
      EXPORTING
        text                = lv_msg
        flag_no_line_breaks = 'X'
        line_length         = '55'
        langu               = sy-langu
      TABLES
        text_tab            = lt_text_tab.


    IF <fs_nfetx_tab> IS ASSIGNED.
      lt_nfetx = <fs_nfetx_tab>.
    ENDIF.

    SORT lt_nfetx BY seqnum DESCENDING.

    LOOP AT lt_text_tab ASSIGNING FIELD-SYMBOL(<fs_msg1>).

      lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
      lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

      ADD 1 TO lv_seq.

      IF <fs_nfetx_tab> IS ASSIGNED.
        APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_msg1> ) TO <fs_nfetx_tab>.
      ENDIF.

      cs_header-infcpl = |{ cs_header-infcpl }  { <fs_msg1> }|.

      CLEAR: lv_msg.
    ENDLOOP.

  ENDIF.

ENDLOOP.
