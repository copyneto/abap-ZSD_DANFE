***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: SD - XML e Danfe: Ajsute Acumular itens                *
*** AUTOR    : Victor Santos Araujo Silva - META                      *
*** FUNCIONAL: Jana Castilhos - META                                  *
*** DATA     : 22.04.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 22.04.2022 | Victor Santos Araujo Silva | Desenvolvimento inicial *
***********************************************************************
*&---------------------------------------------------------------------*
*& Include          ZSDI_VERIF_COLIGADA
*&---------------------------------------------------------------------*
IF sy-uname EQ 'VARAUJO' or sy-uname EQ 'JCASTILHOS'.

  CONSTANTS: lc_coligada  TYPE char4 VALUE '0002'.

  FIELD-SYMBOLS: <fs_imposto_acumula> TYPE ty_j_1bnfstx,
                 <fs_item_acumula>    TYPE ty_j_1bnflin.

  ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM_TAX[]') TO <fs_imposto_acumula>.
  ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM[]') TO <fs_item_acumula>.

  IF it_doc-partyp EQ 'C'.
    SELECT SINGLE bpkind
      INTO @DATA(lv_coligada)
      FROM but000
      WHERE partner = @it_doc-parid.

    IF lv_coligada NE lc_coligada.

      IF <fs_item_acumula> IS ASSIGNED AND <fs_imposto_acumula> IS ASSIGNED.
        DATA(lo_acumular_itens) = NEW zclsd_acumular_itens( ).

        lo_acumular_itens->execute(

        CHANGING
        ct_item = <fs_item_acumula>
        ct_imposto = <fs_imposto_acumula>
        ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
