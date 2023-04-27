"!<p>Classe utilizada para tratar <strong>FECOP e ICMS na NF</strong>. <br/>
"! Esta classe é utilizada na BADI <em>J_1BNF_ADD_DATA</em> para tratativa de: <br/>
"! <ul>
"! <li>Informações adicionais no cabeçalho da NF relacionadas a FECOP e ICMS; </li>
"! <li>Separação de alíquota FECOP e ICMS; </li>
"! <li>Informações adicionais no item da NF relacionadas a FECOP e ICMS. </li>
"! </ul>
"! <br/><br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 18/08/2021</p>
class ZCLSD_TEXTOS_INFCPL_INFADPROD definition
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
  methods UPDATE_INFCPL
    changing
      !CS_HEADER type J_1BNF_BADI_HEADER .
  methods UPDATE_INFADPROD .
  methods GET_ITEM
    returning
      value(RT_RESULT) type J_1BNF_BADI_ITEM_TAB .
  methods GET_ADD_HEADER
    returning
      value(RS_ADD_RESULT) type J_1BNF_BADI_HEADER .
ENDCLASS.



CLASS ZCLSD_TEXTOS_INFCPL_INFADPROD IMPLEMENTATION.


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


  method execute.

    " Atualiza textos Header
    me->update_infcpl(
      changing
        cs_header = cs_nfheader
    ).



  endmethod.


  method GET_ADD_HEADER.
    rs_add_result = me->gs_add_header.
  endmethod.


  method GET_ITEM.
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


  method UPDATE_INFADPROD.
  endmethod.


METHOD update_infcpl.

  DATA:
    lv_matnr      TYPE j_1bnflin-matnr,
    lv_matnr_c    TYPE char40,
    lv_docnum     TYPE j_1bnflin-docnum,
    lv_docnum_c   TYPE char10,
    lv_cest       TYPE j_1bnflin-cest,
    lv_cest_c     TYPE char9,
    lv_nbm        TYPE j_1bnflin-nbm,
    lv_nbm_c      TYPE char16,
    lv_vicmsdif   TYPE j_1bnflin-vicmsdif,
    lv_vicmsdif_c TYPE char18,
    lv_taxval     TYPE j_1bnfstx-taxval,
    lv_taxval_c   TYPE char18,
    lv_othbas     TYPE j_1bnfstx-othbas,
    lv_othbas_c   TYPE char18,
    lv_ii_c       TYPE char12,
    lv_ddi_c      TYPE char12,
    lt_mensagens  TYPE TABLE OF tline,
    lt_msg        LIKE LINE OF lt_mensagens.

  DATA(ls_nf_header) = me->get_nf_header( ).

  DATA(lt_nflin) = me->get_nflin( ).

  DATA(lt_nfstx) = me->get_nfstx( ).

  DATA(ls_add_header) = me->get_add_header( ).

  SORT lt_nfstx BY taxtyp docnum.
  LOOP AT lt_nflin INTO DATA(ls_nflin).
    CLEAR: lv_matnr_c, lv_docnum_c, lv_cest_c, lv_nbm_c, lv_vicmsdif_c.

    lv_matnr_c     = ls_nflin-matnr.
    lv_docnum_c    = ls_nflin-docnum.
    lv_cest_c      = ls_nflin-cest.
    lv_nbm_c       = ls_nflin-nbm.
    lv_vicmsdif_c  = ls_nflin-vicmsdif.
    SHIFT lv_vicmsdif_c LEFT DELETING LEADING space.

    CONCATENATE
                cs_header-infcpl
                TEXT-001 lv_matnr_c
                TEXT-002 lv_docnum_c
                TEXT-003 lv_cest_c
                TEXT-004 lv_nbm_c
                TEXT-005 lv_vicmsdif_c
                INTO cs_header-infcpl
                SEPARATED BY space.

    SHIFT cs_header-infcpl LEFT DELETING LEADING space.

    READ TABLE lt_nfstx INTO DATA(ls_nfstx) WITH KEY taxtyp = 'IPI1'
                                                  docnum = ls_nflin-docnum BINARY SEARCH.
    CLEAR: lv_taxval_c, lv_othbas_c.
    IF ls_nfstx-taxval > 0.
      lv_taxval_c = ls_nfstx-taxval.
      CONCATENATE
                cs_header-infcpl
                TEXT-006  lv_taxval_c
                INTO cs_header-infcpl
                SEPARATED BY space.
    ENDIF.

    IF ls_nfstx-othbas > 0.
      lv_othbas_c = ls_nfstx-othbas.
      CONCATENATE
          cs_header-infcpl
          TEXT-007  lv_othbas_c
          INTO cs_header-infcpl
          SEPARATED BY space.
    ENDIF.

  ENDLOOP.


ENDMETHOD.
ENDCLASS.
