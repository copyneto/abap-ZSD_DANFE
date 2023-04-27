*&---------------------------------------------------------------------*
*& Include          ZSDI_REGIME_ESPECIAL_MG
*&---------------------------------------------------------------------*
    CONSTANTS: lc_centro    TYPE ztca_param_par-chave1 VALUE 'WERKS'.
    DATA: lt_centro         TYPE TABLE OF j_1bnflin.
    DATA: lr_centro_mg      TYPE RANGE OF j_1bnflin-werks.

    DATA(lo_regime_especial) = NEW zclca_tabela_parametros( ).


    TRY.
        lo_regime_especial->m_get_range(
          EXPORTING
            iv_modulo = lc_sd
            iv_chave1 = lc_centro
          IMPORTING
            et_range  = lr_centro_mg ).
      CATCH zcxca_tabela_parametros.
        CLEAR lr_centro_mg.
    ENDTRY.

    DATA(lv_text_re) = CONV char950( |{ TEXT-f71 } { TEXT-f72 } { TEXT-f73 }| ).

    IF lr_centro_mg IS NOT INITIAL.
      lt_centro = VALUE #( FOR ls_it IN it_nflin WHERE ( werks IN lr_centro_mg )
                                                       ( CORRESPONDING #( ls_it ) ) ).
      IF lt_centro  IS NOT INITIAL.

        IF gv_manual EQ abap_true AND sy-tcode NE lc_j1b2n.
          ASSIGN ('(SAPLJ1BB2)WK_FTX[]') TO <fs_nfetx_man>.
          IF <fs_nfetx_man> IS ASSIGNED.
            lt_nfetx = <fs_nfetx_man>.

            SORT lt_nfetx BY seqnum DESCENDING.

            lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
            lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

            ADD 1 TO lv_seq.

            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f71 ) TO <fs_nfetx_man>.
            ADD 1 TO lv_linnum.
            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f72 ) TO <fs_nfetx_man>.
            ADD 1 TO lv_linnum.
            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f73 ) TO <fs_nfetx_man>.

            SEARCH cs_header-infcpl FOR lv_text_re.
            IF sy-subrc NE 0.
              cs_header-infcpl = |{ cs_header-infcpl } { lv_text_re } |.
            ENDIF.
          ENDIF.
        ELSE.

          ASSIGN ('(SAPLJ1BG)WNFFTX[]') TO <fs_nfetx_tab>.
          IF NOT <fs_nfetx_tab> IS ASSIGNED.
            ASSIGN ('(SAPLJ1BF)WA_NF_FTX[]') TO <fs_nfetx_tab>.
          ENDIF.
          IF <fs_nfetx_tab> IS ASSIGNED.
            lt_nfetx = <fs_nfetx_tab>.

            SORT lt_nfetx BY seqnum DESCENDING.

            FIND lv_text_re IN TABLE lt_nfetx.
            IF sy-subrc NE 0.

              lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
              lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

              ADD 1 TO lv_seq.

              APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f71 ) TO <fs_nfetx_tab>.
              ADD 1 TO lv_linnum.
              APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f72 ) TO <fs_nfetx_tab>.
              ADD 1 TO lv_linnum.
              APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = TEXT-f73 ) TO <fs_nfetx_tab>.

            ENDIF.

*            cs_header-infcpl = |{ cs_header-infcpl } { TEXT-f71 } { TEXT-f72 } { TEXT-f73 }|.

          ENDIF.

*          lv_text_re = CONV char950( |{ TEXT-f71 } { TEXT-f72 } { TEXT-f73 }| ).
          SEARCH cs_header-infcpl FOR lv_text_re.
          IF sy-subrc NE 0.
            cs_header-infcpl = |{ cs_header-infcpl } { lv_text_re } |.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
