*&---------------------------------------------------------------------*
*& Include          ZMMI_FILL_TEXT_MM
*&---------------------------------------------------------------------*

DATA: lr_emp_mg TYPE RANGE OF lifnr.
DATA: lr_trans TYPE RANGE OF bsart.

DATA lv_texto_aux TYPE string.

CHECK it_nflin IS NOT INITIAL.

CLEAR lv_texto.

LOOP AT it_nflin INTO DATA(ls_item).

  IF ls_item-refkey IS NOT INITIAL.

    SELECT SINGLE ekko~bsart, ekko~lifnr
      INTO @DATA(ls_ekko)
      FROM ekko AS ekko
      INNER JOIN mseg AS mseg ON mseg~ebeln = ekko~ebeln
      WHERE mseg~mblnr = @ls_item-refkey(10)
        AND mseg~mjahr = @ls_item-refkey+10(4).
    IF sy-subrc IS NOT INITIAL.

      SELECT SINGLE ekko~bsart, ekko~lifnr
        INTO @ls_ekko
        FROM ekko AS ekko
       INNER JOIN ekpo
          ON ekko~ebeln = ekpo~ebeln
       WHERE ekpo~ebeln = @ls_item-xped
         AND ekpo~ebelp = @ls_item-nitemped.

    ENDIF.

    IF ls_ekko IS NOT INITIAL.

      SELECT SINGLE bu_sort1
        INTO @DATA(lv_termo)
        FROM but000
       WHERE partner = @ls_ekko-lifnr.

      DATA(lv_lifnr) = CONV lifnr( |{ ls_ekko-lifnr ALPHA = OUT }| ).

    ENDIF.

    SELECT *
      INTO TABLE @DATA(lt_param)
      FROM ztca_param_val
      WHERE modulo = 'MM'
        AND chave1 = 'TIPO PEDIDO'.
    IF sy-subrc IS INITIAL.
      LOOP AT  lt_param ASSIGNING FIELD-SYMBOL(<fs_param>).
        APPEND VALUE #( sign = 'I' option = 'EQ' low = CONV bsart( <fs_param>-low ) ) TO lr_trans.
      ENDLOOP.
    ENDIF.

    IF lr_trans[] IS NOT INITIAL AND ls_ekko-bsart IN lr_trans[].

      lv_texto = |{ TEXT-f68 } { ls_item-refkey(10) } / { ls_item-refkey+10(4) }|.
      CONDENSE lv_texto.

      lv_texto_aux = |{ lv_texto }|.

      IF ls_item-cest IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_CCEST_OUTPUT'
          EXPORTING
            input  = ls_item-cest
          IMPORTING
            output = ls_item-cest.

*  lv_texto = |{ TEXT-f67 } { lv_lifnr } { lv_termo } { TEXT-f68 }{ ls_item-refkey(10) } / { ls_item-refkey+10(4) } { TEXT-f69 }{ ls_item-matnr ALPHA = OUT }{ TEXT-f70 }{ ls_item-cest }|.

        lv_texto = |{ to_upper( TEXT-f69 ) } { ls_item-matnr ALPHA = OUT } { to_upper( TEXT-f70 ) } { ls_item-cest }|.
        CONDENSE lv_texto.

        SEARCH cs_header-infcpl FOR lv_texto.
        IF sy-subrc NE 0.
          lv_texto_aux = |{ lv_texto_aux } { lv_texto }|.
        ENDIF.

        lv_texto = lv_texto_aux.

      ENDIF.

      SEARCH cs_header-infcpl FOR lv_texto.
      IF sy-subrc NE 0.

        cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.

        IF <fs_nfetx_tab> IS ASSIGNED.
          lt_nfetx = <fs_nfetx_tab>.

          SORT lt_nfetx BY seqnum DESCENDING.

          lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
          lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
          ADD 1 TO lv_seq.

          APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
        ENDIF.
      ENDIF.

    ENDIF.

    SELECT *
      INTO TABLE lt_param
      FROM ztca_param_val
      WHERE modulo = 'MM'
        AND chave1 = 'EMP. 2600'.
    IF sy-subrc IS INITIAL.
      LOOP AT  lt_param ASSIGNING <fs_param>.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = CONV lifnr( <fs_param>-low ) ) TO lr_emp_mg.
      ENDLOOP.
    ENDIF.

    IF lr_emp_mg[] IS NOT INITIAL AND lv_lifnr IN lr_emp_mg[].

      FREE lt_param.

      SELECT *
        INTO TABLE lt_param
        FROM ztca_param_val
        WHERE modulo = 'MM'
          AND chave1 = 'TRANSFERENCIA MG'.
      IF sy-subrc IS INITIAL.
        SORT  lt_param BY chave2.

        LOOP AT lt_param ASSIGNING <fs_param>.

          IF lv_texto IS INITIAL.
            lv_texto = <fs_param>-low.
          ELSE.
            lv_texto = |{ lv_texto } { <fs_param>-low }|.
          ENDIF.

        ENDLOOP.

        IF lv_texto IS NOT INITIAL.
          IF <fs_nfetx_tab> IS ASSIGNED.
            lt_nfetx = <fs_nfetx_tab>.

            SORT lt_nfetx BY seqnum DESCENDING.

            lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
            lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
            ADD 1 TO lv_seq.

            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
            cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
          ENDIF.

          CLEAR: lv_texto.
        ENDIF.

        lv_texto = |{ TEXT-f68 } { ls_item-refkey(10) } / { ls_item-refkey+10(4) }|.
        CONDENSE lv_texto.

        lv_texto_aux = |{ lv_texto }|.

        IF ls_item-cest IS NOT INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_CCEST_OUTPUT'
            EXPORTING
              input  = ls_item-cest
            IMPORTING
              output = ls_item-cest.

*    lv_texto = |{ TEXT-f67 } { lv_lifnr } { lv_termo } { TEXT-f68 }{ ls_item-refkey(10) } / { ls_item-refkey+10(4) } { TEXT-f69 } { ls_item-matnr ALPHA = OUT } { TEXT-f70 } { ls_item-cest }|.
          lv_texto = |{ lv_texto } { to_upper( TEXT-f69 ) } { ls_item-matnr ALPHA = OUT } { to_upper( TEXT-f70 ) } { ls_item-cest }|.
          CONDENSE lv_texto.

          SEARCH cs_header-infcpl FOR lv_texto.
          IF sy-subrc NE 0.
            lv_texto_aux = |{ lv_texto_aux } { lv_texto }|.
          ENDIF.

          lv_texto = lv_texto_aux.

          IF <fs_nfetx_tab> IS ASSIGNED.
            lt_nfetx = <fs_nfetx_tab>.

            SORT lt_nfetx BY seqnum DESCENDING.

            lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
            lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).
            ADD 1 TO lv_seq.

            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = lv_texto ) TO <fs_nfetx_tab>.
*        cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.
          ENDIF.

        ENDIF.

      ENDIF.

      SEARCH cs_header-infcpl FOR lv_texto.
      IF sy-subrc NE 0.
        cs_header-infcpl = |{ cs_header-infcpl } { lv_texto }|.
      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR lv_texto.

ENDLOOP.
