*&---------------------------------------------------------------------*
*& Include          ZSDI_CARACTER_ESPECIAIS_HEADER
*&---------------------------------------------------------------------*
 IF lv_infcpl_mt EQ abap_true.
   cs_header-infcpl    = lo_trata_caracter_especial->execute( iv_text = cs_header-infcpl  ).
 ENDIF.
