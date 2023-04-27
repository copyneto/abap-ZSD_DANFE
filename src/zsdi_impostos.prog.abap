*&---------------------------------------------------------------------*
*& Include          ZSDI_IMPOSTOS
*&---------------------------------------------------------------------**

        DATA: BEGIN OF ls_tpcondicao,
                irrf   TYPE prcd_elements-kschl VALUE 'BW42',
                csll   TYPE prcd_elements-kschl VALUE 'BW32',
                pis    TYPE prcd_elements-kschl VALUE 'BW12',
                cofins TYPE prcd_elements-kschl VALUE 'BW22',
              END OF ls_tpcondicao.

        DATA: lv_irrf        TYPE prcd_elements-kwert,
              lv_csll        TYPE prcd_elements-kwert,
              lv_pis         TYPE prcd_elements-kwert,
              lv_cofins      TYPE prcd_elements-kwert,
              lv_irrf_s      TYPE char30,
              lv_csll_s      TYPE char30,
              lv_pis_s       TYPE char30,
              lv_cofins_s    TYPE char30,
              lv_total_imp_s TYPE char30,
              lv_val_a_pg_s  TYPE char30,
              lv_count       TYPE i.

        lo_num_pedido = NEW zclca_tabela_parametros( ).

        TRY.
            lo_num_pedido->m_get_range(
              EXPORTING
                iv_modulo = lc_modulo
                iv_chave1 = lc_key1_imp
                iv_chave2 = lc_key2_imp
              IMPORTING
                et_range  = lr_tp_fat ).
          CATCH zcxca_tabela_parametros.

        ENDTRY.

        IF lr_tp_fat IS NOT INITIAL AND is_vbrk-fkart IN lr_tp_fat.

*          SELECT knumv, kschl, kwert
*            FROM prcd_elements
*            INTO TABLE @DATA(lt_elements)
*            WHERE knumv = @is_vbrk-knumv
*              AND kschl IN ( @ls_tpcondicao-irrf,
*                             @ls_tpcondicao-csll,
*                             @ls_tpcondicao-pis,
*                             @ls_tpcondicao-cofins ).

*          IF sy-subrc = 0.

*            LOOP AT lt_elements ASSIGNING FIELD-SYMBOL(<fs_elements>).
*
*              CASE <fs_elements>-kschl.
*                WHEN ls_tpcondicao-irrf  .
*                  lv_irrf = lv_irrf + ( is_header-nftot * ( <fs_elements>-kwert / 100 ) ).
*                WHEN ls_tpcondicao-csll  .
*                  lv_csll = lv_csll + ( is_header-nftot * ( <fs_elements>-kwert / 100 ) ).
*                WHEN ls_tpcondicao-pis   .
*                  lv_pis = lv_pis + ( is_header-nftot * ( <fs_elements>-kwert / 100 ) ).
*                WHEN ls_tpcondicao-cofins.
*                  lv_cofins = lv_cofins + ( is_header-nftot * ( <fs_elements>-kwert / 100 ) ).
*              ENDCASE.
*
*            ENDLOOP.

          IF it_vbrp IS NOT INITIAL.

            LOOP AT it_vbrp ASSIGNING FIELD-SYMBOL(<fs_vbrp_x>).

              lv_irrf   = lv_irrf   + <fs_vbrp_x>-kzwi3.
              lv_csll   = lv_csll   + <fs_vbrp_x>-kzwi4.
              lv_pis    = lv_pis    + <fs_vbrp_x>-kzwi5.
              lv_cofins = lv_cofins + <fs_vbrp_x>-kzwi6.

            ENDLOOP.

            WRITE: lv_irrf   TO lv_irrf_s,
                   lv_csll   TO lv_csll_s,
                   lv_pis    TO lv_pis_s,
                   lv_cofins TO lv_cofins_s.

            CONDENSE: lv_irrf_s,
                      lv_csll_s,
                      lv_pis_s,
                      lv_cofins_s NO-GAPS.

            DO 3 TIMES.

              ADD 1 TO lv_count.

              IF lv_count = 1.

                lv_texto = |{ TEXT-f60 }|.
                REPLACE '&1' IN lv_texto WITH lv_irrf_s.
                REPLACE '&2' IN lv_texto WITH lv_csll_s.
                REPLACE '&3' IN lv_texto WITH lv_pis_s.
                REPLACE '&4' IN lv_texto WITH lv_cofins_s.

              ELSEIF lv_count = 2.

                DATA(lv_total_imp) = CONV vfprc_element_value( lv_irrf + lv_csll + lv_pis + lv_cofins ).
                WRITE lv_total_imp TO lv_total_imp_s.
                CONDENSE lv_total_imp_s NO-GAPS.
                lv_texto = |{ TEXT-f61 } { lv_total_imp_s }|.

              ELSEIF lv_count = 3.

                DATA(lv_val_a_pg) = CONV j_1bnftot( is_header-nftot - lv_total_imp ).
                WRITE lv_val_a_pg TO lv_val_a_pg_s.
                CONDENSE lv_val_a_pg_s NO-GAPS.
                lv_texto = |{ TEXT-f62 } { lv_val_a_pg_s }|.

              ENDIF.

              IF lv_texto IS NOT INITIAL.

                CONDENSE lv_texto.

                lt_nfetx = <fs_nfetx_tab>.

                SORT lt_nfetx BY seqnum DESCENDING.

                lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
                lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

                ADD 1 TO lv_seq.
                IF <fs_nfetx_tab> IS ASSIGNED.
                  APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
                  cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
                ENDIF.

                CLEAR: lv_texto.

              ENDIF.

            ENDDO.

          ENDIF.

        ENDIF.
