*&---------------------------------------------------------------------*
*& Include          ZSDI_TOTAL_NF_CONSIGNACAO
*&---------------------------------------------------------------------*
    CONSTANTS: lc_sd     TYPE ztca_param_par-modulo VALUE 'SD',
               lc_nftype TYPE ztca_param_par-chave1 VALUE 'NFTYPE'.

    DATA lr_nftype TYPE RANGE OF j_1bnfdoc-nftype.

    DATA(lo_nftype) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_nftype->m_get_range(
          EXPORTING
            iv_modulo = lc_sd
            iv_chave1 = lc_nftype
          IMPORTING
            et_range  = lr_nftype ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    IF  nf_header-nftype IN  lr_nftype.
      ext_header-nftot = ext_header-nftot - ext_header_stat-ipival - ext_header_stat-icstval.
    ENDIF.
