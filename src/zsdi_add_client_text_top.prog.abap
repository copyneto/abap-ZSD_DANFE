*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_CLIENT_TEXT_TOP
*&---------------------------------------------------------------------*
   CONSTANTS: lc_partyp   TYPE char1  VALUE 'C',
              lc_partyp_b TYPE char1  VALUE 'B',
              lc_tco      TYPE char2  VALUE '73',
              lc_cat      TYPE char2  VALUE 'TO',
              lc_modulo   TYPE ztca_param_par-modulo  VALUE 'SD',
              lc_chv1     TYPE char7  VALUE 'NFE_TXT',
              lc_chv2     TYPE char16 VALUE 'J_1BNFDOC-BRANCH',
              lc_itmnum   TYPE char6  VALUE '000010',
              lc_kschl    TYPE char4  VALUE 'ZDIF',
              lc_taxtyp   TYPE char4  VALUE 'ICM3',
              lc_taxtyp2  TYPE char4  VALUE 'ICZF',
              lc_j1b2n    TYPE sy-tcode  VALUE 'J1B2N',

              BEGIN OF lc_emenda,
                icep TYPE char4 VALUE 'ICEP',
                icap TYPE char4 VALUE 'ICAP',
                icms TYPE char4 VALUE 'ICSP',
              END OF lc_emenda.

   TYPES: BEGIN OF ty_emenda,
            taxtyp TYPE j_1bnfstx-taxtyp,
            taxval TYPE j_1bnfstx-taxval,
          END OF ty_emenda.

   DATA: lt_emenda_collect TYPE TABLE OF ty_emenda.
   DATA: lr_taxyp_emenda TYPE RANGE OF j_1bnfstx-taxtyp.

* LSCHEPP - SD - 8000007675 - Junç itens Mens diferid e bc icms incorr - 24.05.2023 Início
   TYPES: BEGIN OF ty_mont_dif,
            matnr    TYPE j_1bnflin-matnr,
            vicmsdif TYPE j_1bnfstx-taxval,
          END OF ty_mont_dif.

   DATA: lt_mont_dif TYPE TABLE OF ty_mont_dif,
         ls_mont_dif TYPE ty_mont_dif.
* LSCHEPP - SD - 8000007675 - Junç itens Mens diferid e bc icms incorr - 24.05.2023 Fim

* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Início
   TYPES: BEGIN OF ty_fcp_values,
            itmnum TYPE j_1bnfstx-itmnum,
            taxtyp TYPE j_1bnfstx-taxtyp,
            base   TYPE j_1bnfstx-base,
            taxval TYPE j_1bnfstx-taxval,
          END OF ty_fcp_values.

   DATA: lt_fcp_values TYPE TABLE OF ty_fcp_values,
         ls_fcp_values TYPE ty_fcp_values.
* LSCHEPP - SD - 8000007840 - Quebra de lote - Total FCP e reembolso - 24.05.2023 Fim

   TYPES: ty_t_nfetx TYPE TABLE OF j_1bnfftx.

   DATA: lt_text_tab TYPE TABLE OF string,
         lv_msg      TYPE string.
   DATA: lv_btd_id   TYPE /scmtms/btd_id.
   DATA: lt_lines    TYPE TABLE OF tline.
   DATA: lv_texto       TYPE tline-tdline,
         lv_matnr       TYPE vbap-matnr,
         lv_name        TYPE thead-tdname,
         lv_taxval      TYPE char15,
         lv_val         TYPE j_1btaxval,
         lv_val2        TYPE j_1btaxval,
         lv_text_emenda TYPE tline-tdline.

   DATA: lv_novokzwi6  TYPE prcd_elements-kbetr,
         lv_kzwi6_aux  TYPE prcd_elements-kbetr,
         lv_vicmsdif   TYPE j_1bnfstx-taxval,
         lv_mont_total TYPE j_1bnfstx-taxval.

   TYPES: ty_t_wnfstx TYPE TABLE OF j_1bnfstx.

   FIELD-SYMBOLS: <fs_wnfstx_tab> TYPE ty_t_wnfstx.

   FIELD-SYMBOLS: <fs_nfetx_tab> TYPE ty_t_nfetx.

   FIELD-SYMBOLS: <fs_nfetx_man> TYPE ty_t_nfetx.

   FIELD-SYMBOLS: <fs_wk_header> TYPE j_1bnfdoc.

   DATA: lo_logbr_factory TYPE REF TO if_nfe_logbr_texts_factory,
         lo_logbr_texts   TYPE REF TO if_nfe_logbr_texts.

   CREATE OBJECT lo_logbr_factory TYPE cl_nfe_logbr_texts_factory.

   DATA(lt_vbrp_aux) = it_vbrp.
   SORT lt_vbrp_aux BY posnr.

   DATA(lt_itens_add) = ct_itens_adicional.
   SORT lt_itens_add BY itmnum.
