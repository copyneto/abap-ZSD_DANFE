*&---------------------------------------------------------------------*
*& Include          ZMMI_LIMPA_CEST_NFE
*&---------------------------------------------------------------------*
CONSTANTS: lc_mm        TYPE ztca_param_par-modulo VALUE 'MM',
           lc_chave1_mm TYPE ztca_param_par-chave1 VALUE 'DANFE',
           lc_chave2_mm TYPE ztca_param_par-chave2 VALUE 'AJUSTES',
           lc_chave3_mm TYPE ztca_param_par-chave3 VALUE 'NF_TYPE'.

DATA lr_nf_type_mm TYPE RANGE OF j_1bnfdoc-nftype .

DATA(lo_param_mm) = NEW zclca_tabela_parametros( ).
TRY.
    lo_param_mm->m_get_range(
      EXPORTING
        iv_modulo = lc_mm
        iv_chave1 = lc_chave1_mm
        iv_chave2 = lc_chave2_mm
        iv_chave3 = lc_chave3_mm
      IMPORTING
        et_range  = lr_nf_type_mm
    ).
  CATCH zcxca_tabela_parametros.
ENDTRY.

IF  is_header-nftype IN lr_nf_type_mm.
  " Verificar se material está com CEST vazio na configuração da J1BTAX.
  " Se sim manter vazio.
  me->clear_cest( EXPORTING it_nflin = it_nflin
                  CHANGING  ct_item  = et_item ).

ENDIF.
