*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_FCP_TEXT
*&---------------------------------------------------------------------*
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*CONSTANTS:lc_icsc TYPE j_1btaxtyp VALUE 'ICSC',
*          lc_icfp TYPE j_1btaxtyp VALUE 'ICFP',
*          lc_fcpo TYPE j_1btaxtyp VALUE 'FCPO',
*          lc_fpso TYPE j_1btaxtyp VALUE 'FPSO',
*          lc_fcp3 TYPE j_1btaxtyp VALUE 'FCP3'.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

DATA: lv_aliq         TYPE char8,
      lv_zeros        TYPE char2,
      lv_aliq_fcp     TYPE j_1bnfstx-base,
      lv_aliq_fcpst   TYPE j_1bnfstx-base,
      lv_base_fcp     TYPE j_1bnfstx-base,
      lv_base_fcpst   TYPE j_1bnfstx-base,
      lv_taxval_fcp   TYPE j_1bnfstx-taxval,
      lv_taxval_fcpst TYPE j_1bnfstx-taxval.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*DATA(lt_tax) = it_nfstx.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim
SORT lt_tax BY itmnum taxtyp.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*READ TABLE lt_tax ASSIGNING FIELD-SYMBOL(<fs_taxtyp>) WITH KEY itmnum = <fs_nflin>-itmnum
READ TABLE lt_tax ASSIGNING <fs_taxtyp> WITH KEY itmnum = <fs_nflin>-itmnum
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim
                                                 taxtyp = lc_icsc BINARY SEARCH.
IF sy-subrc = 0.

  lv_aliq_fcp = <fs_taxtyp>-rate.
  lv_aliq = <fs_taxtyp>-rate.
  CONDENSE lv_aliq.
  SPLIT lv_aliq AT'.' INTO lv_aliq lv_zeros.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*  lv_texto      = |{ TEXT-f30 } { <fs_taxtyp>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_taxtyp>-taxval }|.
*  lv_base_fcp   = lv_base_fcp + <fs_taxtyp>-base.
*  lv_taxval_fcp = lv_taxval_fcp + <fs_taxtyp>-taxval.
  READ TABLE lt_fcp_values ASSIGNING FIELD-SYMBOL(<fs_fcp_values>) WITH KEY matnr = <fs_nflin>-matnr
                                                                            taxtyp = lc_icsc BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_texto      = |{ TEXT-f30 } { <fs_fcp_values>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_fcp_values>-taxval }|.
    lv_base_fcp   = lv_base_fcp + <fs_fcp_values>-base.
    lv_taxval_fcp = lv_taxval_fcp + <fs_fcp_values>-taxval.
  ENDIF.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início

  IF lv_texto IS NOT INITIAL.

    DATA(lv_fcp) = abap_true.

    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.
      CLEAR: lv_texto, lv_aliq.
    ENDIF.

  ENDIF.

ENDIF.

READ TABLE lt_tax ASSIGNING <fs_taxtyp> WITH KEY itmnum = <fs_nflin>-itmnum
                                                 taxtyp = lc_icfp BINARY SEARCH.
IF sy-subrc = 0.
  lv_aliq_fcpst = <fs_taxtyp>-rate.
  lv_aliq = <fs_taxtyp>-rate.
  CONDENSE lv_aliq.
  SPLIT lv_aliq AT'.' INTO lv_aliq lv_zeros.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*  lv_texto        = |{ TEXT-f33 } { <fs_taxtyp>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_taxtyp>-taxval }|.
*  lv_base_fcpst   = lv_base_fcpst + <fs_taxtyp>-base.
*  lv_taxval_fcpst = lv_taxval_fcpst + <fs_taxtyp>-taxval.
  READ TABLE lt_fcp_values ASSIGNING <fs_fcp_values> WITH KEY matnr = <fs_nflin>-matnr
                                                              taxtyp = lc_icfp BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_texto        = |{ TEXT-f33 } { <fs_fcp_values>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_fcp_values>-taxval }|.
    lv_base_fcpst   = lv_base_fcp + <fs_fcp_values>-base.
    lv_taxval_fcpst = lv_taxval_fcp + <fs_fcp_values>-taxval.
  ENDIF.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

  IF lv_texto IS NOT INITIAL AND <fs_item_add>-infadprod IS ASSIGNED.

    DATA(lv_fcpst) = abap_true.

    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
    IF sy-subrc = 0.
      FIND lv_texto IN <fs_item_add>-infadprod.
      IF sy-subrc NE 0.
        <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.
        CLEAR: lv_texto, lv_aliq.

      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.

*IF sy-ucomm = 'OK_POST' OR sy-ucomm = 'WABU_T'.

READ TABLE lt_tax ASSIGNING <fs_taxtyp> WITH KEY itmnum = <fs_nflin>-itmnum
                                                 taxtyp = lc_fcpo
                                                 BINARY SEARCH.
IF sy-subrc = 0.
  lv_aliq = <fs_taxtyp>-rate.
  CONDENSE lv_aliq.
  SPLIT lv_aliq AT'.' INTO lv_aliq lv_zeros.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*  lv_texto      = |{ TEXT-f30 } { <fs_taxtyp>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_taxtyp>-taxval }|.
*  lv_base_fcp   = lv_base_fcp + <fs_taxtyp>-base.
*  lv_taxval_fcp = lv_taxval_fcp + <fs_taxtyp>-taxval.
  READ TABLE lt_fcp_values ASSIGNING <fs_fcp_values> WITH KEY matnr = <fs_nflin>-matnr
                                                              taxtyp = lc_fcpo BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_texto        = |{ TEXT-f30 } { <fs_fcp_values>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_fcp_values>-taxval }|.
    lv_base_fcp   = lv_base_fcp + <fs_fcp_values>-base.
    lv_taxval_fcp = lv_taxval_fcp + <fs_fcp_values>-taxval.
  ENDIF.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

  IF lv_texto IS NOT INITIAL.

    lv_fcp = abap_true.

    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
    IF sy-subrc = 0.
      FIND lv_texto IN <fs_item_add>-infadprod.
      IF sy-subrc NE 0.
        <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.
        CLEAR: lv_texto, lv_aliq.
      ENDIF.
    ENDIF.

  ENDIF.
ENDIF.

READ TABLE lt_tax ASSIGNING <fs_taxtyp> WITH KEY itmnum = <fs_nflin>-itmnum
                                                 taxtyp = lc_fcp3
                                                 BINARY SEARCH.
IF sy-subrc = 0.
  lv_aliq = <fs_taxtyp>-rate.
  CONDENSE lv_aliq.
  SPLIT lv_aliq AT'.' INTO lv_aliq lv_zeros.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*  lv_texto      = |{ TEXT-f30 } { <fs_taxtyp>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_taxtyp>-taxval }|.
*  lv_base_fcp   = lv_base_fcp + <fs_taxtyp>-base.
*  lv_taxval_fcp = lv_taxval_fcp + <fs_taxtyp>-taxval.
  READ TABLE lt_fcp_values ASSIGNING <fs_fcp_values> WITH KEY matnr = <fs_nflin>-matnr
                                                              taxtyp = lc_fcp3 BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_texto        = |{ TEXT-f30 } { <fs_fcp_values>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_fcp_values>-taxval }|.
    lv_base_fcp   = lv_base_fcp + <fs_fcp_values>-base.
    lv_taxval_fcp = lv_taxval_fcp + <fs_fcp_values>-taxval.
  ENDIF.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

  IF lv_texto IS NOT INITIAL.

    lv_fcp = abap_true.

    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
    IF sy-subrc = 0.
      FIND lv_texto IN <fs_item_add>-infadprod.
      IF sy-subrc NE 0.
        <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.
        CLEAR: lv_texto, lv_aliq.
      ENDIF.
    ENDIF.

  ENDIF.
ENDIF.

READ TABLE lt_tax ASSIGNING <fs_taxtyp> WITH KEY itmnum = <fs_nflin>-itmnum
                                                 taxtyp = lc_fpso
                                                 BINARY SEARCH.
IF sy-subrc = 0.
  lv_aliq = <fs_taxtyp>-rate.
  CONDENSE lv_aliq.
  SPLIT lv_aliq AT'.' INTO lv_aliq lv_zeros.

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
*  lv_texto        = |{ TEXT-f33 } { <fs_taxtyp>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_taxtyp>-taxval }|.
*  lv_base_fcpst   = lv_base_fcpst + <fs_taxtyp>-base.
*  lv_taxval_fcpst = lv_taxval_fcpst + <fs_taxtyp>-taxval.
  READ TABLE lt_fcp_values ASSIGNING <fs_fcp_values> WITH KEY matnr = <fs_nflin>-matnr
                                                              taxtyp = lc_fpso BINARY SEARCH.
  IF sy-subrc EQ 0.
    lv_texto        = |{ TEXT-f33 } { <fs_fcp_values>-base } { TEXT-f31 } { lv_aliq }% { TEXT-f32 } { <fs_fcp_values>-taxval }|.
    lv_base_fcpst   = lv_base_fcp + <fs_fcp_values>-base.
    lv_taxval_fcpst = lv_taxval_fcp + <fs_fcp_values>-taxval.
  ENDIF.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

  IF lv_texto IS NOT INITIAL.

    lv_fcpst = abap_true.

    REPLACE ALL OCCURRENCES OF '.' IN lv_texto WITH ','.

    READ TABLE ct_itens_adicional ASSIGNING <fs_item_add> WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
    IF sy-subrc = 0.
      FIND lv_texto IN <fs_item_add>-infadprod.
      IF sy-subrc NE 0.
        <fs_item_add>-infadprod = |{ <fs_item_add>-infadprod } { lv_texto }|.
        CLEAR: lv_texto, lv_aliq.
      ENDIF.
    ENDIF.

  ENDIF.
ENDIF.

*ENDIF.
