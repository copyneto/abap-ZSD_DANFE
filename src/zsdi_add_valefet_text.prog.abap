*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_VALEFET_TEXT
*&---------------------------------------------------------------------*
IF NOT lv_cont_icms IN lr_cont_icms.

  READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
  IF sy-subrc = 0.
    IF <fs_item_add>-vbcefet IS NOT INITIAL.
      lv_texto  = | { TEXT-f42 } { <fs_item_add>-vbcefet } |.
    ENDIF.
    IF <fs_item_add>-vicmsefet IS NOT INITIAL.
      lv_texto  = | { lv_texto } { TEXT-f43 } { <fs_item_add>-vicmsefet }|.
    ENDIF.

    IF lv_texto IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

      CONDENSE: lv_texto.

      FIND lv_texto IN <fs_item_add>-infadprod IN CHARACTER MODE.

      IF sy-subrc NE 0.

        <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.

      ENDIF.

    ENDIF.

    CLEAR: lv_texto.

  ENDIF.

ENDIF.
