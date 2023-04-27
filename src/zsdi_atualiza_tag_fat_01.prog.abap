*&---------------------------------------------------------------------*
*& Include          ZSDI_ATUALIZA_TAG_FAT_01
*&---------------------------------------------------------------------*
    DATA: lt_payment TYPE TABLE OF j_1bnfepayment,
          lt_doc     TYPE j_1bnfdoc.

    FIELD-SYMBOLS <fs_payment> LIKE lt_payment.
    ASSIGN ('(SAPLJ_1B_NFE)WK_PAYMENT[]') TO <fs_payment>.
    IF <fs_payment> IS ASSIGNED.

      DATA(lt_payment_aux) = <fs_payment>.
      SORT lt_payment_aux BY t_pag.
      READ TABLE lt_payment_aux TRANSPORTING NO FIELDS WITH KEY t_pag = 90 BINARY SEARCH .
      IF sy-subrc NE 0.

        FIELD-SYMBOLS <fs_doc> LIKE lt_doc.
        ASSIGN ('(SAPLJ_1B_NFE)WK_HEADER') TO <fs_doc>.
        IF <fs_doc> IS ASSIGNED.
          <fs_doc>-nfat = it_doc-nfenum.
        ENDIF.

      ENDIF.
    ENDIF.
