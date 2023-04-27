*&---------------------------------------------------------------------*
*& Include          ZSDI_ATUALIZA_TAG_FAT
*&---------------------------------------------------------------------*
"Tag <fat>
*    READ TABLE it_nflin ASSIGNING FIELD-SYMBOL(<fs_nflin>) INDEX 1.
*    IF sy-subrc = 0.
*      es_header-nfat  = <fs_nflin>-refkey.
*    ENDIF.
DATA(lt_payment) = et_payment.
SORT lt_payment BY t_pag.

READ TABLE et_payment ASSIGNING FIELD-SYMBOL(<fs_payment>) INDEX 1.
IF <fs_payment> IS ASSIGNED.
  READ TABLE et_payment TRANSPORTING NO FIELDS WITH KEY t_pag = 90 BINARY SEARCH .

  IF sy-subrc EQ 0.
*  es_header-vorig = is_header-nftot.
    es_header-vdesc = '0.00'.
*  es_header-vliq  = is_header-nftot.
    es_header-vliq  = <fs_payment>-v_pag.
    es_header-vorig = <fs_payment>-v_pag.
  ELSE.
      es_header-vliq  = <fs_payment>-v_pag.
      es_header-vorig = <fs_payment>-v_pag.
  ENDIF.
ENDIF.
