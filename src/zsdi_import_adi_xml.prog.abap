*&---------------------------------------------------------------------*
*& Include          ZSDI_IMPORT_ADI_XML
*&---------------------------------------------------------------------*
CONSTANTS lc_nftype TYPE j_1bnftype VALUE 'IO'.
DATA(lt_adi) = wk_import_adi[].
SORT lt_adi BY ndi.
*IF wk_header-nftype EQ lc_nftype.


LOOP AT gt_rfc_prod_di ASSIGNING FIELD-SYMBOL(<fs_di>).
  READ TABLE lt_adi ASSIGNING FIELD-SYMBOL(<fs_import_adi>) WITH KEY ndi = <fs_di>-n_di_2 BINARY SEARCH.
  IF <fs_import_adi> IS ASSIGNED AND <fs_import_adi>-ndi IS NOT INITIAL.
    DATA(lv_ndi_true) = abap_true.
    <fs_di>-n_di = <fs_import_adi>-ndi.
    <fs_di>-seq_no = <fs_import_adi>-nseqadic.
  ENDIF.
ENDLOOP.

IF lv_ndi_true  = abap_true.
  LOOP AT gt_rfc_di_adi ASSIGNING FIELD-SYMBOL(<fs_adi>).
    <fs_adi>-n_seq_adic = <fs_adi>-n_seq_adic_2.
    <fs_adi>-seq_no     = <fs_adi>-n_seq_adic_2.
  ENDLOOP.
ENDIF.
