***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: NFE - Textos Infcpl e Infadprod                        *
*** AUTOR : Tobias Tolfo - META                                       *
*** FUNCIONAL: Jana Castilhos - META                                  *
*** DATA : 11.09.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 11.09.2021 | Tobias Tolfo   | Desenvolvimento inicial         *
***********************************************************************
*&---------------------------------------------------------------------*
*& ZSDI_TEXTOS_INFCPL_INFADPROD
*&---------------------------------------------------------------------*

new zclsd_textos_infcpl_infadprod(
  is_header     = is_header
  it_nflin      = it_nflin
  it_nfstx      = it_nfstx
  it_item       = et_item
  is_add_header = es_header )->execute(
  changing
    cs_nfheader = es_header
    ct_nfitem   = et_item
).
