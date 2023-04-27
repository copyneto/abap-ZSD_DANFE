*&---------------------------------------------------------------------*
*& Include          ZSDI_DEVOLUCAO_FORNECEDOR
*&---------------------------------------------------------------------*

new ZCLSD_DEVOLUCA_FORNECEDOR(
  is_header     = is_header
  it_nflin      = it_nflin
  it_nfstx      = it_nfstx
  it_item       = et_item
  is_add_header = es_header )->execute(
  changing
    cs_nfheader = es_header
    ct_nfitem   = et_item
).
