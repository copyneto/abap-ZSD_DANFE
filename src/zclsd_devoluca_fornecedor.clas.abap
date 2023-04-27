"!<p>Classe utilizada para tratar <strong>FECOP e ICMS na NF</strong>. <br/>
"! Esta classe é utilizada na BADI <em>J_1BNF_ADD_DATA</em> para tratativa de: <br/>
"! <ul>
"! <li>Calcular a tag outro valores </li>
"! </ul>
"! <br/><br/>
"!<p><strong>Autor:</strong> Willian Hazor - Meta</p>
"!<p><strong>Data:</strong> 16/06/2022</p>
class ZCLSD_DEVOLUCA_FORNECEDOR definition
  public
  final
  create public .

public section.

  constants:
      "! Tipos de imposto
    BEGIN OF gc_taxtyp,
        "! ICMS FCP
        icms_fcp TYPE j_1bnfstx-taxtyp VALUE 'ICSC',
        "! Substituição tributária FCP
        st_fcp   TYPE j_1bnfstx-taxtyp VALUE 'ICFP',
      END OF gc_taxtyp .

    "! Construtor - inicialização de objetos
    "! @parameter is_header       | Cabeçalho da NF
    "! @parameter it_nflin        | Itens da NF
    "! @parameter it_nfstx        | Impostos da NF
  methods CONSTRUCTOR
    importing
      !IS_HEADER type J_1BNFDOC
      !IT_NFLIN type J_1BNFLIN_TAB
      !IT_NFSTX type J_1BNFSTX_TAB
      !IT_ITEM type J_1BNF_BADI_ITEM_TAB
      !IS_ADD_HEADER type J_1BNF_BADI_HEADER .
    "! Determina informações da NF de acordo com a regra do FECOP e ICMS na BADI J_1BNF_ADD_DATA
    "! @parameter cs_nfheader         | Cabeçalho atualizado da NF
    "! @parameter ct_nfitem           | Itens atualizados da NF
  methods EXECUTE
    changing
      !CS_NFHEADER type J_1BNF_BADI_HEADER
      !CT_NFITEM type J_1BNF_BADI_ITEM_TAB .
  PROTECTED SECTION.

private section.

  types:
      "! Utilizado no cálculo de Total de impostos
    BEGIN OF ty_tax_total,
        docnum     TYPE j_1bnfstx-docnum,
        itmnum     TYPE j_1bnfstx-itmnum,
        base_sum   TYPE j_1bnfstx-base,
        taxval_sum TYPE j_1bnfstx-taxval,
        rate       TYPE j_1bnfstx-rate,
      END OF ty_Tax_total .

      "! Tabela de Itens da NF importada da BADI
  data GT_NFLIN type J_1BNFLIN_TAB .
      "! Tabela de Impostos da NF importada da BADI
  data GT_NFSTX type J_1BNFSTX_TAB .
      "! Cabeçalho da NF importado da BADI
  data GS_NF_HEADER type J_1BNFDOC .
  data GT_ITEM type J_1BNF_BADI_ITEM_TAB .
  data GS_ADD_HEADER type J_1BNF_BADI_HEADER .

    "! Recupera o cabeçalho da NF
    "! @parameter rs_result         | Cabeçalho da NF
  methods GET_NF_HEADER
    returning
      value(RS_RESULT) type J_1BNFDOC .
    "! Recupera itens da NF
    "! @parameter rt_result         | Itens da NF
  methods GET_NFLIN
    returning
      value(RT_RESULT) type J_1BNFLIN_TAB .
    "! Recupera os impostos da NF
    "! @parameter rt_result     | Impostos da NF
  methods GET_NFSTX
    returning
      value(RT_RESULT) type J_1BNFSTX_TAB .
  methods GET_ADD_HEADER
    returning
      value(RS_ADD_RESULT) type J_1BNF_BADI_HEADER .
ENDCLASS.



CLASS ZCLSD_DEVOLUCA_FORNECEDOR IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    " Cabeçalho da NF
    me->gs_nf_header = is_header.

    " Partidas da NF
    me->gt_nflin = it_nflin.

    " Impostos da NF
    me->gt_nfstx = it_nfstx.

    "Itens Nota
    me->gt_item = it_item.

    "Header Adicionais
    me->gs_add_header = is_add_header.

  ENDMETHOD.


  METHOD execute.

    TYPES: BEGIN OF ty_sum_valor,
             itmnum TYPE j_1bitmnum,
             voutro TYPE j_1bnfe_voutro,
           END OF ty_sum_valor.

    DATA: lt_sum_valor TYPE TABLE OF ty_sum_valor,
          ls_sum_valor TYPE ty_sum_valor,
          LV_voutro TYPE j_1bnfe_voutro.

    CHECK me->gs_nf_header-doctyp = '6'
      and me->gs_nf_header-direct = '2'
      and me->gs_nf_header-nfe    = abap_true.

    FIELD-SYMBOLS <fs_wnfdoc> TYPE j_1bnfdoc.

    LOOP AT gt_nfstx ASSIGNING FIELD-SYMBOL(<fs_nfstx>).
      CHECK <fs_nfstx>-taxtyp = 'ICS1' or <fs_nfstx>-taxtyp = 'ICS2'.

      CHECK <fs_nfstx>-taxval NE 0 AND <fs_nfstx>-othbas NE 0.
      ls_sum_valor-itmnum = <fs_nfstx>-itmnum.
      ls_sum_valor-voutro = <fs_nfstx>-taxval.
      COLLECT ls_sum_valor INTO lt_sum_valor.
      LV_voutro = LV_voutro + <fs_nfstx>-taxval.
    ENDLOOP.

    SORT lt_sum_valor BY itmnum.

    LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      READ TABLE lt_sum_valor ASSIGNING FIELD-SYMBOL(<fs_sum_valor>) with key itmnum = <fs_item>-itmnum BINARY SEARCH.
      if <fs_sum_valor> is ASSIGNED.
        <fs_item>-voutro = <fs_sum_valor>-voutro.
        UNASSIGN <fs_sum_valor>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method GET_ADD_HEADER.
    rs_add_result = me->gs_add_header.
  endmethod.


  METHOD GET_NFLIN.
    rt_result = me->gt_nflin.
  ENDMETHOD.


  METHOD GET_NFSTX.
    rt_result = me->gt_nfstx.
  ENDMETHOD.


  METHOD GET_NF_HEADER.
    rs_result = me->gs_nf_header.
  ENDMETHOD.
ENDCLASS.
