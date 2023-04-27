*&---------------------------------------------------------------------*
*& Include          ZSDI_GET_TAX_MESSAGES
*&---------------------------------------------------------------------*

SELECT SINGLE * FROM  j_1batl4t
       INTO @DATA(ls_j_1batl4t)
       WHERE  langu       EQ @sy-langu
       AND    taxlaw      EQ @<fs_nflin>-taxlw4.

SELECT SINGLE * FROM  j_1batl5t
  INTO @DATA(ls_j_1batl5t)
       WHERE  langu       EQ @sy-langu
       AND    taxlaw      EQ @<fs_nflin>-taxlw5.

SELECT SINGLE * FROM  j_1batl1t
    INTO @DATA(ls_j_1batl1t)
       WHERE  langu       EQ @sy-langu
       AND    taxlaw      EQ @<fs_nflin>-taxlw1.

SELECT SINGLE * FROM  j_1batl2t
      INTO @DATA(ls_j_1batl2t)
       WHERE  langu       EQ @sy-langu
       AND    taxlaw      EQ @<fs_nflin>-taxlw2.


READ TABLE ct_itens_adicional ASSIGNING FIELD-SYMBOL(<fs_itens_add>) WITH KEY itmnum = <fs_nflin>-itmnum BINARY SEARCH.
IF sy-subrc = 0.
  CLEAR  <fs_itens_add>-infadprod.
  IF NOT ls_j_1batl4t IS INITIAL.
    <fs_itens_add>-infadprod = |{ <fs_itens_add>-infadprod } { ls_j_1batl4t-line1 } { ls_j_1batl4t-line2 } { ls_j_1batl4t-line3 } { ls_j_1batl4t-line4 }|.
  ENDIF.

  IF NOT ls_j_1batl5t IS INITIAL.
    <fs_itens_add>-infadprod = |{ <fs_itens_add>-infadprod } { ls_j_1batl5t-line1 } { ls_j_1batl5t-line2 } { ls_j_1batl5t-line3 } { ls_j_1batl5t-line4 }|.
  ENDIF.

  IF NOT ls_j_1batl1t IS INITIAL.
    <fs_itens_add>-infadprod = |{ <fs_itens_add>-infadprod } { ls_j_1batl1t-line1 } { ls_j_1batl1t-line2 } { ls_j_1batl1t-line3 } { ls_j_1batl1t-line4 }|.
  ENDIF.

  IF NOT ls_j_1batl2t IS INITIAL.
    <fs_itens_add>-infadprod = |{ <fs_itens_add>-infadprod } { ls_j_1batl2t-line1 } { ls_j_1batl2t-line2 } { ls_j_1batl2t-line3 } { ls_j_1batl2t-line4 }|.
  ENDIF.

  CONDENSE <fs_itens_add>-infadprod.

ENDIF.
