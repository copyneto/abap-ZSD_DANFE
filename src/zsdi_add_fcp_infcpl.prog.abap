*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_FCP_INFCPL
*&---------------------------------------------------------------------*
DATA: lv_base_fcp_txt     TYPE c LENGTH 18,
      lv_aliq_fcp_txt     TYPE c LENGTH 18,
      lv_taxval_fcp_txt   TYPE c LENGTH 18,
      lv_base_fcpst_txt   TYPE c LENGTH 18,
      lv_taxval_fcpst_txt TYPE c LENGTH 18,
      lv_aliq_fcpst_txt   TYPE c LENGTH 18.

IF lv_fcp EQ abap_true.

  IF lv_base_fcp IS NOT INITIAL.
*       lv_texto = |{ TEXT-f30 } { lv_base_fcp }|.
    WRITE lv_base_fcp TO lv_base_fcp_txt CURRENCY is_header-waerk.
    SHIFT lv_base_fcp_txt LEFT DELETING LEADING space.
    lv_texto = |{ TEXT-f83 } { lv_base_fcp_txt }|.

    IF lv_aliq_fcp IS NOT INITIAL.
      WRITE lv_aliq_fcp TO lv_aliq_fcp_txt CURRENCY is_header-waerk.
      SHIFT lv_aliq_fcp_txt LEFT DELETING LEADING space.
      lv_texto = |{ lv_texto } { TEXT-f84 } { lv_aliq_fcp_txt }|.
    ENDIF.

    IF lv_taxval_fcp IS NOT INITIAL.
*         lv_texto = |{ lv_texto } { TEXT-f32 } { lv_taxval_fcp }|.
      WRITE lv_taxval_fcp TO lv_taxval_fcp_txt CURRENCY is_header-waerk.
      SHIFT lv_taxval_fcp_txt LEFT DELETING LEADING space.
      lv_texto = |{ lv_texto } { TEXT-f85 } { lv_taxval_fcp_txt }|.
    ENDIF.

  ELSEIF lv_taxval_fcp IS NOT INITIAL.
*    lv_texto = |{ TEXT-f32 } { lv_taxval_fcp }|.
    WRITE lv_taxval_fcp TO lv_taxval_fcp_txt CURRENCY is_header-waerk.
    SHIFT lv_taxval_fcp_txt LEFT DELETING LEADING space.
    lv_texto = |{ TEXT-f32 } { lv_taxval_fcp_txt }|.
  ENDIF.

  IF lv_texto IS NOT INITIAL.

*    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    IF <fs_nfetx_tab> IS ASSIGNED.
      lt_nfetx = <fs_nfetx_tab>.

      SORT lt_nfetx BY seqnum DESCENDING.

      lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
      lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
      ADD 1 TO lv_seq.

      APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.

    ENDIF.

    SEARCH cs_header-infcpl FOR lv_texto.
    IF sy-subrc NE 0.
      cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
    ENDIF.

    CLEAR: lv_texto.
  ENDIF.

ENDIF.

IF lv_fcpst EQ abap_true.

  IF lv_base_fcpst IS NOT INITIAL.
*    lv_texto = |{ TEXT-f33 } { lv_base_fcpst }|.
    WRITE lv_base_fcpst TO lv_base_fcpst_txt CURRENCY is_header-waerk.
    SHIFT lv_base_fcpst_txt LEFT DELETING LEADING space.
    lv_texto = |{ TEXT-f86 } { lv_base_fcpst_txt }|.

    IF lv_aliq_fcpst IS NOT INITIAL.
      WRITE lv_aliq_fcpst TO lv_aliq_fcpst_txt CURRENCY is_header-waerk.
      SHIFT lv_aliq_fcpst_txt LEFT DELETING LEADING space.
      lv_texto = |{ lv_texto } { TEXT-f84 } { lv_aliq_fcpst_txt }|.
    ENDIF.

    IF lv_taxval_fcpst IS NOT INITIAL.
*      lv_texto = |{ lv_texto } { TEXT-f32 } { lv_taxval_fcpst }|.
      WRITE lv_taxval_fcpst TO lv_taxval_fcpst_txt CURRENCY is_header-waerk.
      SHIFT lv_taxval_fcpst_txt LEFT DELETING LEADING space.
      lv_texto = |{ lv_texto } { TEXT-f85 } { lv_taxval_fcpst_txt }|.
    ENDIF.

  ELSEIF lv_taxval_fcpst IS NOT INITIAL.
*    lv_texto = |{ TEXT-f32 } { lv_taxval_fcpst }|.
    WRITE lv_taxval_fcpst TO lv_taxval_fcpst_txt CURRENCY is_header-waerk.
    SHIFT lv_taxval_fcpst_txt LEFT DELETING LEADING space.
    lv_texto = |{ lv_texto } { TEXT-f32 } { lv_taxval_fcpst_txt }|.
  ENDIF.

  IF lv_texto IS NOT INITIAL.

*    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    IF <fs_nfetx_tab> IS ASSIGNED.
      lt_nfetx = <fs_nfetx_tab>.

      SORT lt_nfetx BY seqnum DESCENDING.

      lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
      lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
      ADD 1 TO lv_seq.

      APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.

    ENDIF.

    SEARCH cs_header-infcpl FOR lv_texto.
    IF sy-subrc NE 0.
      cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
    ENDIF.

    CLEAR: lv_texto.
  ENDIF.

ENDIF.
