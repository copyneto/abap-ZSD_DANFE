*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_ORDEM_FRETE_TEXT
*&---------------------------------------------------------------------*
 CONSTANTS: BEGIN OF lc_tp_ov,
              y074 TYPE auart VALUE 'Y074',
              y077 TYPE auart VALUE 'Y077',
              yd74 TYPE auart VALUE 'YD74',
              yd77 TYPE auart VALUE 'YD77',
              yr74 TYPE auart VALUE 'YR74',
              yr75 TYPE auart VALUE 'YR75',
              z001 TYPE auart VALUE 'Z001',
            END OF lc_tp_ov.

 DATA(ls_lin) = VALUE #( it_nflin[ 1 ] DEFAULT '' ).

 IF ls_lin-refkey IS NOT INITIAL
AND ls_lin-reftyp EQ 'BI'.

   IF is_vbrk-fkart EQ lc_tp_ov-y074
   OR is_vbrk-fkart EQ lc_tp_ov-y077
   OR is_vbrk-fkart EQ lc_tp_ov-yd74
   OR is_vbrk-fkart EQ lc_tp_ov-yd77
   OR is_vbrk-fkart EQ lc_tp_ov-yr74
   OR is_vbrk-fkart EQ lc_tp_ov-yr75
   OR is_vbrk-fkart EQ lc_tp_ov-z001.
     DATA(lv_nexec) = abap_true.
   ELSE.
     CLEAR lv_nexec.
   ENDIF.
 ENDIF.

 IF ls_lin-reftyp = gc_fat
AND lv_nexec      IS INITIAL.

   DATA(lv_vgbel) = VALUE #( it_vbrp[ 1 ]-vgbel DEFAULT '' ).

   IF lv_vgbel IS NOT INITIAL.

     lv_btd_id = |{ lv_vgbel ALPHA = OUT }|.
     UNPACK lv_btd_id TO lv_btd_id.

     SELECT SINGLE rot~tor_id
       INTO @DATA(lv_tor_id)
       FROM /scmtms/d_tordrf AS drf
      INNER JOIN /scmtms/d_torrot AS rot ON rot~db_key = drf~parent_key
                                        AND drf~btd_tco = @lc_tco
      WHERE drf~btd_id  = @lv_btd_id
        AND rot~tor_cat = @lc_cat.
     IF sy-subrc IS INITIAL.

       IF <fs_nfetx_tab> IS ASSIGNED.
         lt_nfetx = <fs_nfetx_tab>.

         SORT lt_nfetx BY seqnum DESCENDING.

         lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
         lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

         ADD 1 TO lv_seq.

         APPEND VALUE j_1bnfftx( seqnum  = lv_seq
                                 linnum  = lv_linnum
                                 message = |{ TEXT-f15 } { lv_tor_id ALPHA = OUT }| ) TO <fs_nfetx_tab>.
         cs_header-infcpl = |{ cs_header-infcpl } { TEXT-f15 } { lv_tor_id ALPHA = OUT }|.
       ENDIF.

     ENDIF.
   ENDIF.
 ENDIF.
