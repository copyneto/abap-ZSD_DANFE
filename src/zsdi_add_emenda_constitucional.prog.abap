*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_EMENDA_CONSTITUCIONAL
*&---------------------------------------------------------------------*
DATA(lt_emenda_collect_aux) = lt_emenda_collect.

IF <fs_wnfstx_tab> IS ASSIGNED.
  lt_emenda_collect_aux = CORRESPONDING #( <fs_wnfstx_tab> ).
  SORT lt_emenda_collect_aux BY taxtyp.
ENDIF.

lr_taxyp_emenda = VALUE #( sign = 'I'  option = 'EQ' ( low = lc_emenda-icep )
                                                     ( low = lc_emenda-icap )
                                                     ( low = lc_emenda-icms ) ).

LOOP AT lt_emenda_collect_aux ASSIGNING FIELD-SYMBOL(<fs_emenda_aux>).
  DATA(lv_index) = sy-tabix.
  IF <fs_emenda_aux>-taxtyp IN lr_taxyp_emenda.
    DATA(ls_emenda) = <fs_emenda_aux>.
    COLLECT ls_emenda INTO lt_emenda_collect.
  ELSE.
    DELETE lt_emenda_collect_aux INDEX lv_index.
  ENDIF.
ENDLOOP.

SORT lt_nfetx BY seqnum DESCENDING.

IF lt_emenda_collect_aux IS NOT INITIAL.

  ADD 1 TO lv_seq.
  lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

  lv_texto = TEXT-f34.

  IF <fs_nfetx_tab> IS ASSIGNED.
    APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.

    cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
  ENDIF.


  LOOP AT lt_emenda_collect ASSIGNING FIELD-SYMBOL(<fs_emenda>) .

*    CHECK <fs_emenda>-taxval IS NOT INITIAL.

    ADD 1 TO lv_seq.

    lv_taxval = <fs_emenda>-taxval.

    CASE <fs_emenda>-taxtyp.
      WHEN lc_emenda-icep.
        lv_text_emenda = TEXT-f27.
      WHEN lc_emenda-icap.
        lv_text_emenda = TEXT-f28.
      WHEN lc_emenda-icms.
        lv_text_emenda = TEXT-f29.
    ENDCASE.

    REPLACE ALL OCCURRENCES OF ',' IN lv_taxval WITH space.
    REPLACE ALL OCCURRENCES OF '.' IN lv_taxval WITH ','.
    CONDENSE lv_taxval NO-GAPS.

    lv_texto = |{ lv_text_emenda }: { lv_taxval }|.


    IF <fs_nfetx_tab> IS ASSIGNED.
      APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
      cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
    ENDIF.

  ENDLOOP.

ENDIF.
