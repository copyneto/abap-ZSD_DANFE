*&---------------------------------------------------------------------*
*& Include          ZSDI_DADOS_ADD_TRANSPORTADOR
*&---------------------------------------------------------------------*
  CONSTANTS:
    "! Constantes para tabela de parâmetros
    BEGIN OF gc_parametros,
      modulo TYPE ze_param_modulo VALUE 'SD',
      chave1 TYPE ztca_param_par-chave1 VALUE 'ECOMMERCE',
      chave2 TYPE ztca_param_par-chave2 VALUE 'TIPO_EVENTO_SAIDA',
    END OF gc_parametros.

  CONSTANTS:
    lc_btd_tco     TYPE /scmtms/d_tordrf-btd_tco  VALUE '73',
    lc_tor_cat     TYPE /scmtms/d_torrot-tor_cat  VALUE 'TO',
    lc_parvw       TYPE j_1bnfnad-parvw           VALUE 'SP',
    lc_partyp      TYPE j_1bnfnad-partyp          VALUE 'V',
    lc_hora        TYPE j_1bnfdoc-hsaient         VALUE '050000',
    lc_item_cat    TYPE /scmtms/d_torite-item_cat VALUE 'AVR',
    lc_reftyp      TYPE j_1bnflin-reftyp          VALUE 'BI',
    lc_add_time    TYPE t                         VALUE '004000',
    lc_add_time_30 TYPE t                         VALUE '003000'.

  TYPES: ty_nfnad TYPE TABLE OF j_1bnfnad.

  FIELD-SYMBOLS: <fs_nfnad_tab> TYPE ty_nfnad.

  DATA: lv_data   TYPE j_1b_dep_arr_date,
        lv_hora   TYPE j_1b_dep_arr_time,
        ls_nfnad  TYPE j_1bnfnad,
        lv_btd_id TYPE /scmtms/d_tordrf-btd_id,
        lv_vbeln  TYPE vbeln,
        lv_tor_id TYPE /scmtms/tor_id.

  DATA lr_eventcode TYPE RANGE OF /scmtms/d_torexe-event_code.

  DATA lt_docflow TYPE tdt_docflow.

  DATA(lt_item_aux) = it_nflin.
  SORT lt_item_aux BY reftyp.

  READ TABLE lt_item_aux TRANSPORTING NO FIELDS WITH KEY reftyp = lc_reftyp BINARY SEARCH .

  IF sy-subrc = 0.

    READ TABLE it_vbrp ASSIGNING FIELD-SYMBOL(<fs_vbrp_1>) INDEX 1.
    IF sy-subrc EQ 0.

      lv_vbeln = <fs_vbrp_1>-vgbel.

      CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
        EXPORTING
          iv_docnum  = lv_vbeln
        IMPORTING
          et_docflow = lt_docflow.

      SORT lt_docflow BY vbtyp_n.

      READ TABLE lt_docflow ASSIGNING FIELD-SYMBOL(<fs_docflow>) WITH KEY vbtyp_n = 'TMFO' BINARY SEARCH.
      IF sy-subrc EQ 0.

        DATA(lv_docnum) = <fs_docflow>-docnum.

        lv_tor_id = |{ lv_docnum ALPHA = IN }|.

        SELECT SINGLE db_key, tspid
          FROM /scmtms/d_torrot
          INTO @DATA(ls_torid)
          WHERE tor_id EQ @lv_tor_id.
        IF sy-subrc EQ 0.

*    READ TABLE it_vbfa ASSIGNING FIELD-SYMBOL(<fs_vbfa>) INDEX 1.
*    IF sy-subrc = 0.
*      lv_btd_id = <fs_vbfa>-vbelv.
*      UNPACK lv_btd_id TO lv_btd_id.
*
*      SELECT SINGLE _tordrf~parent_key,_torid~db_key,_torid~tspid
*        INTO @DATA(ls_torid)
*        FROM /scmtms/d_tordrf       AS _tordrf
*        INNER JOIN /scmtms/d_torrot AS _torid
*         ON _tordrf~parent_key EQ _torid~db_key
*      WHERE _tordrf~btd_id     EQ @lv_btd_id
*        AND _tordrf~btd_tco    EQ @lc_btd_tco
*        AND _torid~tor_cat     EQ @lc_tor_cat .

          IF ls_torid IS NOT INITIAL.

            "Dados Transportadora
            ASSIGN ('(SAPLJ1BG)wnfnad[]') TO <fs_nfnad_tab>.
            IF <fs_nfnad_tab> IS ASSIGNED AND ls_torid-tspid IS NOT INITIAL.

              DATA(lt_nfnad) = <fs_nfnad_tab>.
              SORT lt_nfnad BY parvw.
              READ TABLE lt_nfnad ASSIGNING FIELD-SYMBOL(<fs_nfnad>) WITH KEY parvw = lc_parvw BINARY SEARCH.

              IF sy-subrc NE 0.
                SELECT SINGLE xcpdk,anred,name1,name2,name3,name4,
                              stras,ort01,ort02,regio,land1,pstlz,
                              pfach,pstl2,sortl,spras,telf1,telfx,
                              telx1,stkzn,txjcd,stcd1,stcd2,stcd3
               INTO @DATA(ls_cliente)
               FROM kna1
              WHERE kunnr = @ls_torid-tspid.

                IF sy-subrc = 0.

                  ls_nfnad = CORRESPONDING #( ls_cliente ).
                  ls_nfnad-parvw  = lc_parvw.
                  ls_nfnad-partyp = lc_partyp.
                  ls_nfnad-parid  = ls_torid-tspid.
                  ls_nfnad-cgc    = ls_cliente-stcd1.
                  ls_nfnad-cpf    = ls_cliente-stcd2.
                  ls_nfnad-stains = ls_cliente-stcd3.

                  APPEND ls_nfnad TO <fs_nfnad_tab>.

                ENDIF.
              ENDIF.
            ENDIF.

            " Placa
            SELECT SINGLE platenumber
              INTO @DATA(lv_placa)
              FROM /scmtms/d_torite
            WHERE parent_key EQ @ls_torid-db_key
              AND item_cat   EQ @lc_item_cat.

            IF lv_placa IS NOT INITIAL.
*    es_header-placa = lv_placa.
*    es_header-uf1   = is_header-regio.
            ENDIF.

            DATA(lo_tabela_parametros) = NEW  zclca_tabela_parametros( ).

            " Busca Data Entrada/Saída Mercadoria
            TRY.
                lo_tabela_parametros->m_get_range( EXPORTING iv_modulo = gc_parametros-modulo
                                                             iv_chave1 = gc_parametros-chave1
                                                             iv_chave2 = gc_parametros-chave2
                                                   IMPORTING et_range  = lr_eventcode ).

                IF lr_eventcode IS NOT INITIAL.

                  SELECT SINGLE actual_date
                    INTO @DATA(lv_dt_hr_saida)
                    FROM /scmtms/d_torexe
*                  WHERE parent_key EQ @ls_torid-parent_key
                  WHERE parent_key EQ @ls_torid-db_key
                    AND event_code IN @lr_eventcode.
                ENDIF.

              CATCH zcxca_tabela_parametros.
            ENDTRY.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


* LSCHEPP - Alteração Data/Hora Saída - Nova Definição - 09.01.2023 Início

***    " Passa Data Entrada/Saída Mercadoria
***    IF lv_dt_hr_saida IS NOT INITIAL.
***
***      CONVERT TIME STAMP lv_dt_hr_saida TIME ZONE sy-zonlo
***                                             INTO DATE lv_data
***                                                  TIME lv_hora.
***
***      IF lv_data NE sy-datum.
***        es_header-dsaient = lv_data.
***        es_header-hsaient = lc_hora.
***      ELSE.
***
***        CALL FUNCTION 'EWU_ADD_TIME'
***          EXPORTING
***            i_starttime = lv_hora
***            i_startdate = lv_data
***            i_addtime   = lc_add_time
***          IMPORTING
***            e_endtime   = lv_hora
***            e_enddate   = lv_data.
***
***        es_header-dsaient = lv_data.
***        es_header-hsaient = lv_hora.
***
***      ENDIF.
***    ELSE.
***
***      lv_data = is_header-docdat.
***      lv_hora = sy-uzeit.
****      lv_hora = is_header-authtime.
***
***      CALL FUNCTION 'EWU_ADD_TIME'
***        EXPORTING
***          i_starttime = lv_hora
***          i_startdate = lv_data
***          i_addtime   = lc_add_time
***        IMPORTING
***          e_endtime   = lv_hora
***          e_enddate   = lv_data.
***
***      es_header-dsaient = lv_data.
***      es_header-hsaient = lv_hora.
***
***    ENDIF.

    CALL FUNCTION 'EWU_ADD_TIME'
      EXPORTING
        i_starttime = sy-uzeit
        i_startdate = sy-datum
        i_addtime   = lc_add_time_30
      IMPORTING
        e_endtime   = lv_hora
        e_enddate   = lv_data.

    es_header-dsaient = lv_data.
    es_header-hsaient = lv_hora.

* LSCHEPP - Alteração Data/Hora Saída - Nova Definição - 09.01.2023 Fim

  ENDIF.
