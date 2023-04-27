*&---------------------------------------------------------------------*
*& Include          ZSDI_CARACTER_ESPECIAIS_ITEM
*&---------------------------------------------------------------------*
    CONSTANTS: lc_chave1_nfe TYPE ztca_param_par-chave1 VALUE 'NFE',
               lc_chave2_car TYPE ztca_param_par-chave2 VALUE 'CARACTERES_ESPEC'.


    DATA lr_regio TYPE RANGE OF j_1bnfdoc-regio.

    DATA(lo_trata_caracter_especial) = NEW zclsd_trata_caracter_especial( ).

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range(
          EXPORTING
            iv_modulo = lc_modulo
            iv_chave1 = lc_chave1_nfe
            iv_chave2 = lc_chave2_car
          IMPORTING
            et_range  = lr_regio
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    CLEAR: lv_regio.

    SELECT SINGLE regio
       FROM t001w
       INTO @lv_regio
       WHERE werks EQ @<fs_nflin>-werks.

    IF lv_regio IN lr_regio AND <fs_item_add> IS ASSIGNED.
      DATA(lv_infcpl_mt) = abap_true.
      <fs_item_add>-infadprod     = lo_trata_caracter_especial->execute( iv_text = <fs_item_add>-infadprod  ).
    ENDIF.
