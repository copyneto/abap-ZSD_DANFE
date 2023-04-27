***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: SD - XML e Danfe                                       *
*** AUTOR    : Victor Santos Araujo Silva - META                      *
*** FUNCIONAL: Jana Castilhos - META                                  *
*** DATA     : 18.04.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 18.04.2022 | Victor Santos Araujo Silva | Desenvolvimento inicial *
***********************************************************************
*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_IND_PRES
*&---------------------------------------------------------------------*
CONSTANTS:
  "! Constantes para tabela de parâmetros
  BEGIN OF lc_parametros,
    modulo TYPE ze_param_modulo VALUE 'SD',
    chave1 TYPE ztca_param_par-chave1 VALUE 'NFE',
    chave2 TYPE ztca_param_par-chave2 VALUE 'IND_PRES',
  END OF lc_parametros.

data: lv_chave3 type ztca_param_par-chave3.

DATA lr_ind_pres TYPE RANGE OF j_1bnf_badi_header-ind_pres.

DATA(lo_tabela_parametros_ind_pres) = NEW zclca_tabela_parametros( ).

lv_chave3 = is_header-nftype.
TRY.
    lo_tabela_parametros_ind_pres->m_get_range(
EXPORTING
        iv_modulo = lc_parametros-modulo
        iv_chave1 = lc_parametros-chave1
        iv_chave2 = lc_parametros-chave2
        iv_chave3 = lv_chave3
IMPORTING
        et_range  =  lr_ind_pres
).

  CATCH zcxca_tabela_parametros.

ENDTRY.

READ TABLE lr_ind_pres ASSIGNING FIELD-SYMBOL(<fs_ind_pres>) INDEX 1.

IF <fs_ind_pres> IS ASSIGNED.
  es_header-ind_pres = <fs_ind_pres>-low.
ENDIF.
