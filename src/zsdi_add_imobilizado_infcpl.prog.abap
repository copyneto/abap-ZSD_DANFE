*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_IMOBILIZADO_INFCPL
*&---------------------------------------------------------------------*
    TYPES: BEGIN OF ty_eqp,
             invnr TYPE anla-invnr,
           END OF ty_eqp.

    DATA: lt_eqp TYPE STANDARD TABLE OF ty_eqp.

    CONSTANTS: lc_nfe          TYPE ztca_param_par-chave1 VALUE 'NFE',
               lc_comodato     TYPE ztca_param_par-chave2 VALUE 'TP_COMODATO',
               lc_material     TYPE ztca_param_par-chave2 VALUE 'TP_MATNR',
               lc_danfe        TYPE ztca_param_par-chave1 VALUE 'DANFE',
               lc_intercompany TYPE ztca_param_par-chave2 VALUE 'INTERCOMPANY',
               lc_dadosadd     TYPE ztca_param_par-chave3 VALUE 'DADOSADD',
               lc_coligada     TYPE char4                 VALUE '0002',
               lc_pedido       TYPE vbfa-vbtyp_v          VALUE 'G',
               lc_remessa      TYPE vbfa-vbtyp_v          VALUE 'J',
               lc_remessa_t    TYPE vbfa-vbtyp_v          VALUE 'T',
               lc_debito       TYPE vbfa-vbtyp_v          VALUE 'O',
               lc_fatura       TYPE vbfa-vbtyp_n          VALUE 'M',
               lc_key1_imp     TYPE ztca_param_par-chave1 VALUE 'ATIVAR',
               lc_key2_imp     TYPE ztca_param_par-chave2 VALUE 'FKART'.

    CONSTANTS: BEGIN OF lc_tp_ovd,
                 y074 TYPE auart VALUE 'Y074',
                 y075 TYPE auart VALUE 'Y075',
                 y076 TYPE auart VALUE 'Y076',
                 y077 TYPE auart VALUE 'Y077',
                 yd76 TYPE auart VALUE 'YD76',
                 yd77 TYPE auart VALUE 'YD77',
               END OF lc_tp_ovd.

    DATA: lr_material TYPE RANGE OF mara-mtart,
          lr_tp_ordem TYPE RANGE OF vbrk-fkart.

    DATA: lv_comdloc TYPE char1,
          lv_sernr   TYPE objk-sernr,
          lv_anln1   TYPE anla-anln1.


    ASSIGN ('(SAPLJ1BG)WNFFTX[]') TO <fs_nfetx_tab>.
    IF NOT <fs_nfetx_tab> IS ASSIGNED.
      ASSIGN ('(SAPLJ1BF)WA_NF_FTX[]') TO <fs_nfetx_tab>.
    ENDIF.

    IF <fs_nfetx_tab> IS ASSIGNED.

      DATA(lo_imobilizado) = NEW zclca_tabela_parametros( ).

      TRY.
          lo_imobilizado->m_get_range( EXPORTING iv_modulo = lc_modulo
                                                 iv_chave1 = lc_nfe
                                                 iv_chave2 = lc_comodato
                                       IMPORTING et_range  = lr_tp_ordem ).
        CATCH zcxca_tabela_parametros.
      ENDTRY.

      IF lr_tp_ordem   IS INITIAL
      OR is_vbrk-fkart NOT IN lr_tp_ordem.

        CLEAR lr_tp_ordem.
        " Intercompany
        TRY.
            lo_imobilizado->m_get_range( EXPORTING iv_modulo = lc_modulo
                                                   iv_chave1 = lc_danfe
                                                   iv_chave2 = lc_intercompany
                                                   iv_chave3 = lc_dadosadd
                                         IMPORTING et_range  = lr_tp_ordem ).
          CATCH zcxca_tabela_parametros.
        ENDTRY.
      ENDIF.

      IF lr_tp_ordem   IS NOT INITIAL
     AND is_vbrk-fkart IN lr_tp_ordem.

        READ TABLE it_nflin ASSIGNING <fs_nflin>
                             WITH KEY reftyp = gc_fat
                             BINARY SEARCH.
        IF sy-subrc IS INITIAL.

          TRY.
              lo_imobilizado->m_get_range( EXPORTING iv_modulo = lc_modulo
                                                     iv_chave1 = lc_nfe
                                                     iv_chave2 = lc_material
                                           IMPORTING et_range  = lr_material ).
            CATCH zcxca_tabela_parametros.
          ENDTRY.

          IF lr_material IS NOT INITIAL.
            SELECT mara~mtart
              FROM mara
              INTO TABLE @DATA(lt_mara)
               FOR ALL ENTRIES IN @it_nflin
             WHERE matnr EQ @it_nflin-matnr
               AND mtart IN @lr_material.
          ENDIF.

          IF lt_mara IS NOT INITIAL.

            READ TABLE it_vbrp ASSIGNING FIELD-SYMBOL(<fs_doc_fat>) INDEX 1.
            IF sy-subrc = 0.

              SELECT SINGLE vgbel
                FROM vbap
                INTO @DATA(lv_pedido)
               WHERE vbeln EQ @<fs_doc_fat>-aubel
                 AND posnr EQ @<fs_doc_fat>-aupos.

              IF lv_pedido IS NOT INITIAL.
                SELECT SINGLE vbeln,
                              bstnk,
                              ihrez
                  FROM vbak
                  INTO @DATA(ls_vbak)
                 WHERE vbeln EQ @lv_pedido.
              ENDIF.
              IF ls_vbak IS INITIAL.
                SELECT SINGLE vbeln,
                              bstnk,
                              ihrez
                  FROM vbak
                  INTO @ls_vbak
                 WHERE vbeln EQ @<fs_doc_fat>-aubel.
              ENDIF.
            ENDIF.

            SELECT SINGLE bpkind
              INTO @DATA(lv_coligada)
              FROM but000
             WHERE partner = @is_header-parid.

            IF lv_coligada EQ lc_coligada.

              IF ls_vbak IS NOT INITIAL.

                lt_nfetx = <fs_nfetx_tab>.

                SORT lt_nfetx BY seqnum DESCENDING.

                lv_seq    = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
                lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

                ADD 1 TO lv_seq.

                IF ls_vbak-bstnk IS NOT INITIAL.

                  lv_texto = |{ TEXT-f49 }: { ls_vbak-bstnk }|.

                  IF <fs_nfetx_tab> IS ASSIGNED.
                    ADD 1 TO lv_seq.
                    APPEND VALUE j_1bnfftx( seqnum  = lv_seq
                                            linnum  = lv_linnum
                                            message = lv_texto ) TO <fs_nfetx_tab>.
                    cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.
                  ENDIF.

                  CLEAR: lv_texto.

                ENDIF.

                IF ls_vbak-ihrez IS NOT INITIAL.
                  lv_texto = |{ TEXT-f50 }: { ls_vbak-ihrez }|.

                  IF <fs_nfetx_tab> IS ASSIGNED.
                    ADD 1 TO lv_seq.
                    APPEND VALUE j_1bnfftx( seqnum  = lv_seq
                                            linnum  = lv_linnum
                                            message = lv_texto ) TO <fs_nfetx_tab>.
                    cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.
                  ENDIF.
                  CLEAR: lv_texto.

                ENDIF.
              ENDIF.

            ELSE.

              CLEAR lv_comdloc.
              DATA(ls_lin_cmd) = VALUE #( it_nflin[ 1 ] DEFAULT '' ).

              IF ls_lin_cmd-refkey IS NOT INITIAL
             AND ls_lin_cmd-reftyp EQ 'BI' .

                IF is_vbrk-fkart EQ lc_tp_ovd-y076
                OR is_vbrk-fkart EQ lc_tp_ovd-y077
                OR is_vbrk-fkart EQ lc_tp_ovd-yd76
                OR is_vbrk-fkart EQ lc_tp_ovd-yd77.
                  lv_comdloc = abap_true.
                ENDIF.
              ENDIF.

              " Pedido
              IF ls_vbak-bstnk IS NOT INITIAL.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                  EXPORTING
                    input  = ls_vbak-bstnk
                  IMPORTING
                    output = ls_vbak-bstnk.

                IF lv_comdloc IS NOT INITIAL.
                  lv_texto = |{ TEXT-f80 }: { ls_vbak-bstnk }|.
                ELSE.

                  IF is_vbrk-fkart EQ lc_tp_ovd-y074
                  OR is_vbrk-fkart EQ lc_tp_ovd-y075.
                    lv_texto = |{ TEXT-f82 }: { ls_vbak-bstnk }|.
***                ELSE.
***                  lv_texto = |{ TEXT-f51 }: { ls_vbak-bstnk }|.
                  ENDIF.

                ENDIF.
              ENDIF.

              IF lv_comdloc IS NOT INITIAL.
                lv_texto = |{ lv_texto } { TEXT-f81 }: { ls_vbak-ihrez }|.
              ENDIF.

              IF lv_texto IS NOT INITIAL.

                CONDENSE lv_texto.
                lt_nfetx = <fs_nfetx_tab>.

                SORT lt_nfetx BY seqnum DESCENDING.

                lv_seq    = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
                lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

                ADD 1 TO lv_seq.
                IF <fs_nfetx_tab> IS ASSIGNED.
                  APPEND VALUE j_1bnfftx( seqnum  = lv_seq
                                          linnum  = lv_linnum
                                          message = lv_texto ) TO <fs_nfetx_tab>.
                  cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.
                ENDIF.

                CLEAR: lv_texto.
              ENDIF.

              DATA(lt_vbfa) = it_vbfa[].
              SORT lt_vbfa[]  BY vbtyp_v vbtyp_n.
              READ TABLE it_vbfa ASSIGNING FIELD-SYMBOL(<fs_vbfa>)
                                               WITH KEY vbtyp_v = lc_remessa
                                                        vbtyp_n = lc_fatura
                                                        BINARY SEARCH.
              IF sy-subrc NE 0.
                READ TABLE it_vbfa ASSIGNING <fs_vbfa>
                                    WITH KEY vbtyp_v = lc_remessa_t
                                             vbtyp_n = lc_debito
                                             BINARY SEARCH.
                IF sy-subrc IS NOT INITIAL
               AND <fs_vbfa> IS ASSIGNED.
                  UNASSIGN <fs_vbfa>.
                ENDIF.
              ENDIF.

*            IF <fs_vbfa> IS NOT INITIAL.
              IF <fs_vbfa> IS ASSIGNED.
                DATA(lv_remessa) = <fs_vbfa>-vbelv.
              ELSE.
                lv_remessa = VALUE #( it_vbfa[ 1 ]-vbelv OPTIONAL ).
              ENDIF.

              IF lv_remessa IS NOT INITIAL.

                SELECT a~obknr,
                       a~lief_nr,
                       b~sernr
                  FROM ser01 AS a
                 INNER JOIN objk AS b ON b~obknr = a~obknr
                 WHERE a~lief_nr EQ @lv_remessa
                  INTO TABLE @DATA(lt_obknr).

                IF sy-subrc IS INITIAL.

                  LOOP AT lt_obknr ASSIGNING FIELD-SYMBOL(<fs_obknr>).

                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                      EXPORTING
                        input  = <fs_obknr>-sernr
                      IMPORTING
                        output = lv_sernr.

                    lt_eqp = VALUE #( BASE lt_eqp ( invnr = lv_sernr ) ).

                  ENDLOOP.

                  IF lt_eqp[] IS NOT INITIAL.

                    SELECT invnr,
                           anln1
                      FROM anla
                       FOR ALL ENTRIES IN @lt_eqp
                     WHERE invnr EQ @lt_eqp-invnr
                      INTO TABLE @DATA(lt_anla).

                    IF sy-subrc IS INITIAL.
                      SORT lt_anla BY invnr.
                    ENDIF.
                  ENDIF.

                  lt_nfetx = <fs_nfetx_tab>.
                  SORT lt_nfetx BY seqnum DESCENDING.

                  lv_seq    = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
                  lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

                  LOOP AT lt_obknr ASSIGNING <fs_obknr>.

                    IF is_vbrk-fkart NE lc_tp_ovd-y076
                   AND is_vbrk-fkart NE lc_tp_ovd-y077.

                      " Plaqueta
                      IF <fs_obknr>-sernr IS NOT INITIAL.

                        lv_sernr = <fs_obknr>-sernr.

                        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                          EXPORTING
                            input  = lv_sernr
                          IMPORTING
                            output = lv_sernr.

                        lv_texto = |{ TEXT-f52 }: { lv_sernr }|.
                      ENDIF.

                      " Imobilizado
                      IF lv_sernr IS NOT INITIAL.
                        READ TABLE lt_anla ASSIGNING FIELD-SYMBOL(<fs_anla>)
                                                         WITH KEY invnr = lv_sernr
                                                         BINARY SEARCH.
                        IF sy-subrc IS INITIAL.
                          lv_anln1 = <fs_anla>-anln1.

                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                            EXPORTING
                              input  = lv_anln1
                            IMPORTING
                              output = lv_anln1.

                          lv_texto = |{ lv_texto } { TEXT-f53 }: { lv_anln1 }|.
                        ENDIF.
                      ENDIF.

                      IF lv_texto IS NOT INITIAL.
                        ADD 1 TO lv_seq.
                        IF <fs_nfetx_tab> IS ASSIGNED.
                          APPEND VALUE j_1bnfftx( seqnum = lv_seq
                                                  linnum = lv_linnum
                                                  message = lv_texto ) TO <fs_nfetx_tab>.
                          cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.
                          CLEAR lv_texto.
                        ENDIF.
                      ENDIF.

                    ENDIF.
                  ENDLOOP.
                ENDIF.

*              IF lv_obknr   IS NOT INITIAL
*             AND ( is_vbrk-fkart NE lc_tp_ovd-y076 AND
*                   is_vbrk-fkart NE lc_tp_ovd-y077 ).
*
*                SELECT SINGLE sernr
*                  FROM objk
*                  INTO @DATA(lv_sernr)
*                 WHERE obknr EQ @lv_obknr.
*
*                " Plaqueta
*                IF lv_sernr IS NOT INITIAL.
*                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*                    EXPORTING
*                      input  = lv_sernr
*                    IMPORTING
*                      output = lv_sernr.
*
*                  lv_texto = |{ lv_texto } { TEXT-f52 }: { lv_sernr }|.
*                ENDIF.
*              ENDIF.
              ENDIF.

*            IF lv_sernr IS NOT INITIAL
*           AND ( is_vbrk-fkart NE lc_tp_ovd-y076 AND
*                 is_vbrk-fkart NE lc_tp_ovd-y077 ).
*
*              SELECT SINGLE anln1
*                FROM anla
*                INTO @DATA(lv_anln1)
*               WHERE invnr EQ @lv_sernr.
*
*              " Imobilizado
*              IF lv_anln1 IS NOT INITIAL.
*                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*                  EXPORTING
*                    input  = lv_anln1
*                  IMPORTING
*                    output = lv_anln1.
*
*                lv_texto = |{ lv_texto } { TEXT-f53 }: { lv_anln1 }|.
*              ENDIF.
*            ENDIF.
*
*            IF lv_texto IS NOT INITIAL.
*
*              CONDENSE lv_texto.
*
*              lt_nfetx = <fs_nfetx_tab>.
*
*              SORT lt_nfetx BY seqnum DESCENDING.
*
*              lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
*              lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
*
*              ADD 1 TO lv_seq.
*              IF <fs_nfetx_tab> IS ASSIGNED.
*                APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
*                cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
*              ENDIF.
*
*              CLEAR: lv_texto.
*
*            ENDIF.
            ENDIF.

          ENDIF.

        ENDIF.
      ENDIF.

    ENDIF.
