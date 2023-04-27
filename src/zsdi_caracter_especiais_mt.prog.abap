*&---------------------------------------------------------------------*
*& Include          ZSDI_CARACTER_ESPECIAIS_MT
*&---------------------------------------------------------------------*
    CONSTANTS: lc_modulo TYPE ztca_param_mod-modulo VALUE 'SD',
               lc_chave1 TYPE ztca_param_par-chave1 VALUE 'NFE',
               lc_chave2 TYPE ztca_param_par-chave2 VALUE 'CARACTERES_ESPEC'.

    DATA: ls_header     TYPE j_1bnfdoc,
          ls_xmlh       TYPE j1b_nf_xml_header,
          ls_active     TYPE j_1bnfe_active,
          lt_item       TYPE TABLE OF j_1bnflin,
          lt_header_msg TYPE TABLE OF j_1bnfftx.

    DATA lr_regio TYPE RANGE OF j_1bnfdoc-regio.

    DATA(lo_trata_caracter_especial) = NEW zclsd_trata_caracter_especial( ).

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range(
          EXPORTING
            iv_modulo = lc_modulo
            iv_chave1 = lc_chave1
            iv_chave2 = lc_chave2
          IMPORTING
            et_range  = lr_regio
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.


    SELECT SINGLE regio
    FROM t001w
    INTO @DATA(lv_regio)
    WHERE werks EQ @it_lin-werks.

*    FIELD-SYMBOLS <fs_active> LIKE ls_active.
*    ASSIGN ('(SAPLJ_1B_NFE)WK_ACTIVE') TO <fs_active>.

*    IF <fs_active> IS ASSIGNED.

*      IF <fs_active>-regio IN lr_regio.

    IF lv_regio IN lr_regio.

      FIELD-SYMBOLS <fs_header> LIKE ls_header.
      ASSIGN ('(SAPLJ_1B_NFE)WK_HEADER') TO <fs_header>.
      IF <fs_header> IS ASSIGNED.
        <fs_header>-natop     = lo_trata_caracter_especial->execute( iv_text = <fs_header>-natop   ).
      ENDIF.

      FIELD-SYMBOLS <fs_xmlh> LIKE ls_xmlh.
      ASSIGN ('(SAPLJ_1B_NFE)XMLH') TO <fs_xmlh>.
      IF <fs_xmlh> IS ASSIGNED.
        <fs_xmlh>-c_xnome     = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c_xnome    ).
        <fs_xmlh>-c_xfant     = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c_xfant    ).
        <fs_xmlh>-c1_xlgr     = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c1_xlgr    ).
        <fs_xmlh>-f_xcpl      = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-f_xcpl     ).
        <fs_xmlh>-c1_xbairro  = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c1_xbairro ).
        <fs_xmlh>-c1_xmun     = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c1_xmun    ).
        <fs_xmlh>-c1_xpais    = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-c1_xpais   ).
        <fs_xmlh>-infcomp     = lo_trata_caracter_especial->execute( iv_text = <fs_xmlh>-infcomp    ).
      ENDIF.

      FIELD-SYMBOLS <fs_item> LIKE lt_item.
      ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM[]') TO <fs_item>.
      IF <fs_item> IS ASSIGNED.
        LOOP AT <fs_item> ASSIGNING FIELD-SYMBOL(<fs_item_aux>).
          <fs_item_aux>-xprod     = lo_trata_caracter_especial->execute( iv_text = <fs_item_aux>-xprod    ).
        ENDLOOP.
      ENDIF.

      FIELD-SYMBOLS <fs_header_msg> LIKE lt_header_msg.
      ASSIGN ('(SAPLJ_1B_NFE)WK_HEADER_MSG[]') TO <fs_header_msg>.
      IF <fs_item> IS ASSIGNED.
        LOOP AT <fs_header_msg> ASSIGNING FIELD-SYMBOL(<fs_header_msg_aux>).
          <fs_header_msg_aux>-message = lo_trata_caracter_especial->execute( iv_text = <fs_header_msg_aux>-message ).
        ENDLOOP.
      ENDIF.

* LSCHEPP - Tratamento Caracter Especial NF Writer - 24.05.2022 Início
      FIELD-SYMBOLS <fs_wk_item_text> TYPE j_1bnflin_text_tab.
      ASSIGN ('(SAPLJ_1B_NFE)WK_ITEM_TEXT[]') TO <fs_wk_item_text>.
      IF <fs_wk_item_text> IS ASSIGNED.
        LOOP AT <fs_wk_item_text> ASSIGNING FIELD-SYMBOL(<fs_item_text1>).
          <fs_item_text1>-text = lo_trata_caracter_especial->execute( iv_text = <fs_item_text1>-text ).
        ENDLOOP.
      ENDIF.
* LSCHEPP - Tratamento Caracter Especial NF Writer - 24.05.2022 Fim

    ENDIF.

*    ENDIF.
