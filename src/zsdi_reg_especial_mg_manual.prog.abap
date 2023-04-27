*&---------------------------------------------------------------------*
*& Include          ZSDI_REGiME_ESPECIAL_MG_MANUAL
*&---------------------------------------------------------------------*
CONSTANTS: lc_mod_sd     TYPE ztca_param_par-modulo VALUE 'SD'.
CONSTANTS: lc_centro_mg  TYPE ztca_param_par-chave1 VALUE 'WERKS'.
DATA: lt_centro_mg       TYPE TABLE OF j_1bnflin.
DATA: lr_centro_esp_mg   TYPE RANGE OF j_1bnflin-werks.

DATA(lo_regime_especial_mg) = NEW zclca_tabela_parametros( ).

TRY.
    lo_regime_especial_mg->m_get_range(
      EXPORTING
        iv_modulo = lc_mod_sd
        iv_chave1 = lc_centro_mg
      IMPORTING
        et_range  = lr_centro_esp_mg ).
  CATCH zcxca_tabela_parametros.
    CLEAR lr_centro_esp_mg.
ENDTRY.


IF lr_centro_esp_mg IS NOT INITIAL.
  lt_centro_mg = VALUE #( FOR ls_it IN it_nflin WHERE ( werks IN lr_centro_esp_mg )
                                                   ( CORRESPONDING #( ls_it ) ) ).
  IF lt_centro_mg  IS NOT INITIAL.

    cs_header-infcpl = |{ cs_header-infcpl } { TEXT-f71 } { TEXT-f72 }|.

  ENDIF.
ENDIF.
