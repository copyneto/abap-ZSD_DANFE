CLASS zclsd_acumular_itens DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: gt_item TYPE TABLE OF j_1bnflin.
    DATA: gt_imposto TYPE TABLE OF j_1bnfstx.

    METHODS soma_itens
      CHANGING
        !ct_item    LIKE gt_item
        !ct_imposto LIKE gt_imposto.


    METHODS execute
      CHANGING
        !ct_item    LIKE gt_item
        !ct_imposto LIKE gt_imposto.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLSD_ACUMULAR_ITENS IMPLEMENTATION.


  METHOD soma_itens.
    TYPES:
      BEGIN OF ty_itens_soma,
        matnr       TYPE j_1bnflin-matnr,
        menge       TYPE j_1bnflin-menge,
        netpr       TYPE j_1bnflin-netpr,
        netwr       TYPE j_1bnflin-netwr,
        netfre      TYPE j_1bnflin-netfre,
        netins      TYPE j_1bnflin-netins,
        netoth      TYPE j_1bnflin-netoth,
        netdis      TYPE j_1bnflin-netdis,
        nfpri       TYPE j_1bnflin-nfpri,
        nfnet       TYPE j_1bnflin-nfnet,
        nfdis       TYPE j_1bnflin-nfdis,
        nffre       TYPE j_1bnflin-nffre,
        nfins       TYPE j_1bnflin-nfins,
        nfoth       TYPE j_1bnflin-nfoth,
        netwrt      TYPE j_1bnflin-netwrt,
        nfnett      TYPE j_1bnflin-nfnett,
        vicmsdeson  TYPE j_1bnflin-vicmsdeson,
        nficmsdeson TYPE j_1bnflin-nficmsdeson,
        vicmsdif    TYPE j_1bnflin-vicmsdif,
        vicmsstret  TYPE j_1bnflin-vicmsstret,
        vbcstret    TYPE j_1bnflin-vbcstret,
        menge_trib  TYPE j_1bnflin-menge_trib,
        vbcfcpstret TYPE j_1bnflin-vbcfcpstret,
        vfcpstret   TYPE j_1bnflin-vfcpstret,
        vbcstdest   TYPE j_1bnflin-vbcstdest,
        vicmsstdest TYPE j_1bnflin-vicmsstdest,
        vbcefet     TYPE j_1bnflin-vbcefet,
        vicmsefet   TYPE j_1bnflin-vicmsefet,
        base        TYPE j_1bnfstx-base,
        taxval      TYPE j_1bnfstx-taxval,
        excbas      TYPE j_1bnfstx-excbas,
        othbas      TYPE j_1bnfstx-othbas,
      END OF ty_itens_soma.


    DATA: ls_itens_soma TYPE ty_itens_soma.

    DATA: lt_itens_soma TYPE TABLE OF ty_itens_soma.

    DATA(lt_item) = ct_item[].

    SORT lt_item BY matnr ASCENDING.

    SORT ct_imposto by itmnum.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      ls_itens_soma = CORRESPONDING #( <fs_item> ).

      READ TABLE ct_imposto[] ASSIGNING FIELD-SYMBOL(<fs_imposto>) WITH KEY itmnum = <fs_item>-itmnum BINARY SEARCH.

      IF <fs_imposto> IS ASSIGNED.
        ls_itens_soma-base   = <fs_imposto>-base.
        ls_itens_soma-taxval = <fs_imposto>-taxval.
        ls_itens_soma-excbas = <fs_imposto>-excbas.
        ls_itens_soma-othbas = <fs_imposto>-othbas.
      ENDIF.

      COLLECT ls_itens_soma INTO lt_itens_soma.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM ct_item[] COMPARING matnr.

    SORT lt_itens_soma by matnr.
    SORT ct_item by itmnum.

    LOOP AT ct_imposto[] ASSIGNING FIELD-SYMBOL(<fs_impostos>).
      DATA(lv_tabix) = sy-tabix.

      READ TABLE ct_item[] ASSIGNING FIELD-SYMBOL(<fs_item_final>) WITH KEY itmnum = <fs_impostos>-itmnum BINARY SEARCH.
      IF <fs_item_final> IS ASSIGNED.

        READ TABLE lt_itens_soma ASSIGNING FIELD-SYMBOL(<fs_itens_soma>) WITH KEY matnr = <fs_item_final>-matnr BINARY SEARCH.

        IF <fs_itens_soma> IS ASSIGNED.
          <fs_item_final> = CORRESPONDING #( <fs_itens_soma> ).
        ENDIF.


        <fs_impostos>-base   = <fs_itens_soma>-base.
        <fs_impostos>-taxval = <fs_itens_soma>-taxval.
        <fs_impostos>-excbas = <fs_itens_soma>-excbas.
        <fs_impostos>-othbas = <fs_itens_soma>-othbas.

      ELSE.

        DELETE ct_imposto[] INDEX lv_tabix.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD execute.
    soma_itens( CHANGING ct_item = ct_item[]
                         ct_imposto  = ct_imposto[] ).
  ENDMETHOD.
ENDCLASS.
