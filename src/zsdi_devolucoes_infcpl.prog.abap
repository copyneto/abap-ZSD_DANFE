*&---------------------------------------------------------------------*
*& Include zsdi_devolucoes_infcpl
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  STRUCTURES                                                          *
*----------------------------------------------------------------------*

CONSTANTS: lc_sd_dvl     TYPE ztca_param_par-modulo VALUE 'SD',
           lc_chave1_dvl TYPE ztca_param_par-chave1 VALUE 'REEMBOLSO NFE',
           lc_chave2_dvl TYPE ztca_param_par-chave2 VALUE 'REGRA'.

DATA lr_nf_regio TYPE RANGE OF  j_1bnfdoc-regio.

* Nota Fiscal header structure -----------------------------------------
DATA: ls_header TYPE j_1bnfdoc.

* Nota Fiscal item structure -------------------------------------------
DATA: lt_item TYPE TABLE OF j_1bnflin.

* Nota Fiscal item tax structure ---------------------------------------
DATA: lt_item_tax TYPE TABLE OF j_1bnfstx.

DATA: lt_doc_partner TYPE TABLE OF j_1bnfnad.
DATA: lt_doc_header_msg TYPE TABLE OF j_1bnfftx.
DATA: lt_doc_refer_msg TYPE TABLE OF j_1bnfref.

DATA lv_text(1000) TYPE c.
DATA lv_text_item(1000) TYPE c.
DATA lv_icmsst_d TYPE p.
DATA lv_stfcp_d TYPE p.

DATA: ls_line TYPE tline,
      lt_line TYPE TABLE OF tdline.

lv_text = TEXT-f75. "Devolução parcial -> "Default"

IF is_header-doctyp = '6'
  AND is_header-direct = '2'
  AND is_header-nfe    = abap_true
  AND is_header-docnum IS INITIAL.

  CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
    EXPORTING
      doc_number         = is_header-docref
    IMPORTING
      doc_header         = ls_header
    TABLES
      doc_partner        = lt_doc_partner
      doc_item           = lt_item
      doc_item_tax       = lt_item_tax
      doc_header_msg     = lt_doc_header_msg
      doc_refer_msg      = lt_doc_refer_msg
    EXCEPTIONS
      document_not_found = 1
      docum_lock         = 2
      OTHERS             = 3.

  IF sy-subrc EQ 0.

    DATA(lv_regra) = |{ lc_chave2_dvl } { sy-index }|.

    SELECT DISTINCT chave2
    FROM ztca_param_val
    WHERE modulo = @lc_sd_dvl
      AND chave1 = @lc_chave1_dvl
      AND low = @is_header-regio
    INTO TABLE @DATA(lt_regra).

    DATA(lv_dt_emissao) = |{ ls_header-docdat DATE = USER }|.

    SELECT ncm, cest
      FROM j_1btcestdet
       FOR ALL ENTRIES IN @it_nflin
     WHERE ncm EQ @it_nflin-nbm
      INTO TABLE @DATA(lt_cest).

    IF lines( it_nflin ) EQ lines( lt_item ). "Qtde items devolução = Qtde items referência

      DATA(lv_delta) = REDUCE menge_d( INIT sum = 0
                                        FOR ls_nflin    IN it_nflin
                                        FOR ls_item_aux IN lt_item WHERE ( docnum = ls_nflin-docref AND itmnum = ls_nflin-itmref )
                                       NEXT sum += ls_item_aux-menge - ls_nflin-menge ).

      IF lv_delta IS INITIAL.
        "Devolução total
        lv_text = TEXT-f74.
      ENDIF.

    ENDIF.

    lv_text = |{ lv_text } { ls_header-nfenum } - { TEXT-001 } { ls_header-series } { TEXT-f64 } { lv_dt_emissao }|.

    LOOP AT it_nflin ASSIGNING FIELD-SYMBOL(<fs_txt_item>).

* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
      SEARCH cs_header-infcpl FOR TEXT-f49.
      IF sy-subrc NE 0.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim
        lv_text = COND #( WHEN <fs_txt_item>-xped IS NOT INITIAL THEN |{ lv_text } { TEXT-f54 } { <fs_txt_item>-xped }| ELSE space ).
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Início
      ENDIF.
* LSCHEPP - 8000006297 - Erro Dados Adicionais NF Distrato MACRO - 05.04.2023 Fim

      lv_text_item = |{ lv_text_item } { TEXT-f21 } { <fs_txt_item>-vbcstret }|.

      LOOP AT lt_regra ASSIGNING FIELD-SYMBOL(<fs_regra>).

        CASE <fs_regra>-chave2.
          WHEN 'REGRA 1'.
            lv_text_item = |{ lv_text_item } { TEXT-f22 } { ( <fs_txt_item>-vbcstret * <fs_txt_item>-pst - <fs_txt_item>-pfcpstret ) - ( <fs_txt_item>-vbcefet * ( <fs_txt_item>-picmsefet - <fs_txt_item>-pfcpstret ) ) }|.
          WHEN 'REGRA 2'.
            lv_text_item = |{ lv_text_item } { TEXT-f22 } { <fs_txt_item>-vicmsstret }|.
          WHEN 'REGRA 3'.
            lv_text_item = |{ lv_text_item } { TEXT-f25 } { <fs_txt_item>-vicmssubstituto }|.
          WHEN OTHERS.
        ENDCASE.

      ENDLOOP.

      lv_text_item = |{ lv_text_item } { TEXT-f23 } { <fs_txt_item>-vbcfcpstret CURRENCY = is_header-waerk NUMBER = USER }|.

      LOOP AT lt_regra ASSIGNING <fs_regra>.

        CASE <fs_regra>-chave2.
          WHEN 'REGRA 1'.
            lv_text_item = |{ lv_text_item } { TEXT-f24 } { ( <fs_txt_item>-vbcstret * <fs_txt_item>-pfcpstret ) - ( <fs_txt_item>-vbcefet * <fs_txt_item>-pfcpstret ) }|.
          WHEN 'REGRA 2'.
            lv_text_item = |{ lv_text_item } { TEXT-f24 } { <fs_txt_item>-vfcpstret  }|.
          WHEN 'REGRA 3'.
*            lv_text_item = |{ lv_text_item } { TEXT-f25 } { <fs_txt_item>-vicmssubstituto }|.
          WHEN OTHERS.
        ENDCASE.

      ENDLOOP.

      lv_text_item = |{ lv_text_item } FCI { <fs_txt_item>-nfci }|.

      TRY.
          lv_text_item = |{ lv_text_item } { TEXT-f01 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICZF' ]-taxval ) }|.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      TRY.
          lv_text_item = |{ lv_text_item } { TEXT-f33 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICFP' ]-base   ) }|.
          lv_text_item = |{ lv_text_item } { TEXT-f31 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICFP' ]-rate   ) }|.
          lv_text_item = |{ lv_text_item } { TEXT-f32 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICFP' ]-taxval ) }|.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      TRY.
          lv_text_item = |{ lv_text_item } { TEXT-f30 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICSC' ]-base   ) }|.
          lv_text_item = |{ lv_text_item } { TEXT-f31 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICSC' ]-rate   ) }|.
          lv_text_item = |{ lv_text_item } { TEXT-f32 } { VALUE #( it_nfstx[ itmnum = <fs_txt_item>-itmnum taxtyp = 'ICSC' ]-taxval ) }|.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      ct_itens_adicional[ itmnum = <fs_txt_item>-itmnum ]-infadprod = lv_text_item.

      lv_text = |{ lv_text } { TEXT-f69 } { <fs_txt_item>-itmnum ALPHA = OUT }|.
      lv_text = |{ lv_text } { TEXT-f79 } { <fs_txt_item>-matnr ALPHA = OUT }|.

      TRY.
          lv_text = |{ lv_text } { TEXT-f70 } { lt_cest[ ncm = <fs_txt_item>-nbm ]-cest }|.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      IF strlen( <fs_txt_item>-nbm ) > 10.
        lv_text = |{ lv_text } { TEXT-f78 } { substring( val = <fs_txt_item>-nbm off = strlen( <fs_txt_item>-nbm ) - 2 len = 2 ) }|.
      ENDIF.

      TRY.
          lv_text = |{ lv_text } { TEXT-f76 } { it_nfstx[ docnum = <fs_txt_item>-docnum itmnum = <fs_txt_item>-itmnum taxgrp = 'IPI' ]-othbas }|.
          lv_text = |{ lv_text } { TEXT-f77 } { it_nfstx[ docnum = <fs_txt_item>-docnum itmnum = <fs_txt_item>-itmnum taxgrp = 'IPI' ]-taxval }|.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

    ENDLOOP.

    CALL FUNCTION 'RKD_WORD_WRAP'
      EXPORTING
        textline            = lv_text
        outputlen           = 60
      TABLES
        out_lines           = lt_line
      EXCEPTIONS
        outputlen_too_large = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    cs_header-infcpl = |{ cs_header-infcpl }  { lv_text }|.

* LSCHEPP - SD - 8000007933 - Ajustar o valor do IPI nos DANFES de dev - 29.05.2023 Início
    IF is_header-nftype NE 'IE'.
* LSCHEPP - SD - 8000007933 - Ajustar o valor do IPI nos DANFES de dev - 29.05.2023 Fim

      APPEND INITIAL LINE TO ct_add_info ASSIGNING FIELD-SYMBOL(<fs_add_info_aux>).

      <fs_add_info_aux>-docnum = is_header-docnum.
      <fs_add_info_aux>-inf_usage = '1'.
      <fs_add_info_aux>-xcampo = 'INFCOMP'.
      LOOP AT lt_line ASSIGNING FIELD-SYMBOL(<fs_tline>).
        CASE sy-tabix.
          WHEN 1.
            <fs_add_info_aux>-xtexto = <fs_tline>.
          WHEN 2.
            <fs_add_info_aux>-xtexto2 = <fs_tline>.
          WHEN 3.
            <fs_add_info_aux>-xtexto3 = <fs_tline>.
          WHEN 4.
            <fs_add_info_aux>-xtexto4 = <fs_tline>.
          WHEN 5.
            <fs_add_info_aux>-xtexto5 = <fs_tline>.
          WHEN 6.
            <fs_add_info_aux>-xtexto6 = <fs_tline>.
          WHEN 7.
            <fs_add_info_aux>-xtexto7 = <fs_tline>.
          WHEN 8.
            <fs_add_info_aux>-xtexto8 = <fs_tline>.
          WHEN 9.
            <fs_add_info_aux>-xtexto9 = <fs_tline>.
          WHEN OTHERS.
            <fs_add_info_aux>-xtexto10 = <fs_tline>.
        ENDCASE.
      ENDLOOP.

* LSCHEPP - SD - 8000007933 - Ajustar o valor do IPI nos DANFES de dev - 29.05.2023 Início
    ENDIF.
* LSCHEPP - SD - 8000007933 - Ajustar o valor do IPI nos DANFES de dev - 29.05.2023 Fim

  ENDIF.

ENDIF.
