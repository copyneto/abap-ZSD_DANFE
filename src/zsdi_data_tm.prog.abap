*&---------------------------------------------------------------------*
*& Include          ZSDI_DATA_TM
*&---------------------------------------------------------------------*
* LSCHEPP - Alteração Data/Hora Saída - Nova Definição - 09.01.2023 Início
***DATA: lr_remessa TYPE RANGE OF /scmtms/d_tordrf-btd_id.
***
***LOOP AT it_vbrp ASSIGNING FIELD-SYMBOL(<fs_vbrp_aux>).
***
***  APPEND INITIAL LINE TO lr_remessa ASSIGNING FIELD-SYMBOL(<fs_remessa>).
***  <fs_remessa>-sign = 'I'.
***  <fs_remessa>-option = 'EQ'.
***  <fs_remessa>-low = |{ <fs_vbrp_aux>-vgbel ALPHA = IN }|.
***
***ENDLOOP.
***
***SORT lr_remessa BY low.
***
***DELETE ADJACENT DUPLICATES FROM lr_remessa COMPARING low.
***DELETE lr_remessa WHERE low = space.
***
***CHECK lr_remessa IS NOT INITIAL.
***
***SELECT db_key, parent_key
***  INTO TABLE @DATA(lt_dfr)
***  FROM /scmtms/d_tordrf
***  WHERE btd_tco = '73'
***    AND btd_id IN @lr_remessa.
***IF sy-subrc IS INITIAL.
***
***  SELECT db_key
***    INTO TABLE @DATA(lt_tor)
***    FROM /scmtms/d_torrot
***    FOR ALL ENTRIES IN @lt_dfr
***    WHERE db_key = @lt_dfr-parent_key
***      AND tor_cat = 'TO'.
***  IF sy-subrc IS INITIAL.
***    SELECT db_key, parent_key, plan_trans_time
***      INTO TABLE @DATA(lt_stp)
***      FROM /scmtms/d_torstp
***      FOR ALL ENTRIES IN @lt_tor
***      WHERE parent_key = @lt_tor-db_key
***      AND stop_seq_pos = 'F'.
***
***    IF sy-subrc IS INITIAL.
***
***      SORT lt_stp BY plan_trans_time ASCENDING.
***
***      DATA(lv_plan_trans_time) = VALUE #( lt_stp[ 1 ]-plan_trans_time OPTIONAL ) .
***
***      CONVERT TIME STAMP lv_plan_trans_time TIME ZONE 'UTC' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***
***      CHECK lv_plan_trans_time IS NOT INITIAL.
***
***      es_header-dsaient = lv_date.
***
***      IF  lv_date NE sy-datum AND lv_date > is_header-pstdat.
***        es_header-hsaient = '050000'.
***      ELSEIF lv_date EQ sy-datum.
***        CALL FUNCTION 'C14B_ADD_TIME'
***          EXPORTING
***            i_starttime = sy-uzeit
***            i_startdate = lv_date
***            i_addtime   = '003000'
***          IMPORTING
***            e_endtime   = es_header-hsaient.
***      ELSE.
***        es_header-hsaient = lv_time.
***      ENDIF.
***
***    ENDIF.
***  ENDIF.
***ENDIF.
* LSCHEPP - Alteração Data/Hora Saída - Nova Definição - 09.01.2023 Fim
