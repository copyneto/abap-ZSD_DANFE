*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_ORDENS_CONSIG
*&---------------------------------------------------------------------*
CONSTANTS:
  lc_fkart_yc62(4) TYPE c VALUE 'YC62',
  lc_fkart_ys62(4) TYPE c VALUE 'YS62',
  lc_fkart_yr62(4) TYPE c VALUE 'YR62',
  lc_fkart_yd62(4) TYPE c VALUE 'YD62',
  lc_fkart_yr65(4) TYPE c VALUE 'YR65',
  lc_fkart_zd00(4) TYPE c VALUE 'ZD00',
  lc_fkart_yd00(4) TYPE c VALUE 'YD00',
  lc_fkart_z010(4) TYPE c VALUE 'Z010',
  lc_vbbp(4)       TYPE c VALUE 'VBBP',
  lc_z010          TYPE tdid VALUE 'Z010',
  lc_ob_vbbp       TYPE tdobject VALUE 'VBBP'.

DATA: lv_docdate      TYPE char10,
      lv_text_icms    TYPE char100,
      lv_text_ipi     TYPE char100,
      lv_text_icms_st TYPE char100,
      lv_sum_icms     TYPE kzwi2,
      lv_sum_ipi      TYPE kzwi3,
      lv_sum_icms_st  TYPE kzwi4,
      lv_refkey       TYPE j_1bnflin-refkey.

DATA lt_out_lines TYPE TABLE OF j_1bmessag.

DATA: lv_name_read  TYPE thead-tdname,
      lt_lines_read TYPE tline_tab.

*DATA: lv_refkey TYPE j_1bnflin-refkey,
*  lv_vbelv  TYPE vbfa-vbelv,
*  lv_docnum TYPE j_1bnflin-docnum,
*  lv_fkart  TYPE vbrk-fkart,
*  lv_nfenum TYPE j_1bnfdoc-nfenum,
*  lv_docdat TYPE j_1bnfdoc-docdat.

*"Busca J_1BNFLIN-REFKEY
*DATA(lt_nflin_refkey) = it_nflin.
*SORT lt_nflin_refkey BY refkey.
*READ TABLE lt_nflin_refkey ASSIGNING FIELD-SYMBOL(<fs_j_1bnflin_refkey>) INDEX 1.
*
*IF <fs_j_1bnflin_refkey> IS ASSIGNED.
*
*  lv_refkey = <fs_j_1bnflin_refkey>-refkey.

*" Busca VBFA-VBELV
*  DATA(lt_vbfa_vbelv) = it_vbfa.
*  SORT lt_vbfa_vbelv BY vbeln.
*  READ TABLE lt_vbfa_vbelv ASSIGNING FIELD-SYMBOL(<fs_vbfa_vbelv>) INDEX 1.
*     WITH KEY  vbeln = lv_refkey
*               posnn = '000010'
*               vbtyp_n = 'M'.

*  IF <fs_vbfa_vbelv> IS ASSIGNED.
*    lv_vbelv = <fs_vbfa_vbelv>-vbelv.

*  "   Busca J_1BNFLIN-DOCNUM
*  DATA(lt_j_1bnflin_docnum) = it_nflin.
*  SORT lt_j_1bnflin_docnum BY docnum.
*  READ TABLE lt_j_1bnflin_docnum ASSIGNING FIELD-SYMBOL(<fs_j_1bnflin_docnum>)
*   WITH KEY refkey = lv_vbelv.
*
*  IF <fs_j_1bnflin_docnum> IS ASSIGNED.
*    lv_docnum = <fs_j_1bnflin_docnum>-docnum.
*
*    "     Definição VBRK-FKART
*    IF is_vbrk-vbeln = lv_vbelv.
*      lv_fkart = is_vbrk-fkart.
*    ENDIF.
*
*    "     Definição J_1BNFDOC-NFENUM e J_1BNFDOC-DOCDAT
*    lv_nfenum = is_header-nfenum.
*    lv_docdat = is_header-docdat.
*
*  ENDIF.

ASSIGN ('(SAPLJ1BG)WNFFTX[]') TO <fs_nfetx_tab>.
IF NOT <fs_nfetx_tab> IS ASSIGNED.
  ASSIGN ('(SAPLJ1BF)WA_NF_FTX[]') TO <fs_nfetx_tab>.
ENDIF.

IF <fs_nfetx_tab> IS ASSIGNED.

  DATA(lt_vbrp) = it_vbrp.
  READ TABLE lt_vbrp ASSIGNING FIELD-SYMBOL(<fs_vbrp1>) INDEX 1.

  IF <fs_vbrp1> IS ASSIGNED.

    SELECT COUNT( * )
      FROM vbfa
      WHERE vbeln   EQ @<fs_vbrp1>-vgbel
        AND posnn   EQ @<fs_vbrp1>-vgpos
        AND vbtyp_v EQ 'H'. "Devoluções

    IF sy-subrc EQ 0.

      IF NOT <fs_vbrp1>-aubel IS INITIAL.
        SELECT SINGLE xblnr
          FROM vbak
          INTO @DATA(lv_xblnr)
          WHERE vbeln = @<fs_vbrp1>-aubel.
        IF NOT lv_xblnr IS INITIAL.
          SELECT SINGLE budat_mkpf
            FROM mseg
            INTO @DATA(lv_budat_mkpf)
            WHERE xblnr_mkpf = @lv_xblnr
              AND bwart IN ( 'YG6', 'YG8' ).
        ENDIF.
      ENDIF.

      DATA(lv_nfenum) = CONV j_1bnfnum9( lv_xblnr ).
      DATA(lv_docdat) =  lv_budat_mkpf.

* LSCHEPP - SD - 8000007294 - Danfe x XML Dev Despesa Sem mens referen - 15.05.2023 Início
      IF lv_docdat IS INITIAL OR
         lv_nfenum IS INITIAL.
        SELECT SINGLE vbelv
          FROM vbfa
         WHERE vbeln   EQ @<fs_vbrp1>-vgbel
           AND posnn   EQ @<fs_vbrp1>-vgpos
           AND vbtyp_v EQ 'M'
          INTO @DATA(lv_vbelv1).
        IF sy-subrc EQ 0.
          SELECT SINGLE a~nfenum, a~docdat
            FROM j_1bnfdoc AS a
            INNER JOIN j_1bnflin AS b ON a~docnum = b~docnum
            INTO ( @lv_nfenum, @lv_docdat )
            WHERE b~refkey EQ @lv_vbelv1.
        ENDIF.
      ENDIF.
* LSCHEPP - SD - 8000007294 - Danfe x XML Dev Despesa Sem mens referen - 15.05.2023 Fim

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          input        = lv_docdat
        IMPORTING
          output       = lv_docdate
        EXCEPTIONS
          invalid_date = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message).
      ENDIF.

      IF NOT lv_nfenum IS INITIAL AND lv_docdate IS INITIAL.

        lv_name_read = |{ <fs_vbrp1>-vbelv }{ <fs_vbrp1>-posnv }|.

        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_z010
            language                = sy-langu
            name                    = lv_name_read
            object                  = lc_ob_vbbp
          TABLES
            lines                   = lt_lines_read
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.

        IF sy-subrc IS INITIAL.
          LOOP AT lt_lines_read ASSIGNING FIELD-SYMBOL(<fs_lines_read>).
            lv_docdate = |{ <fs_lines_read>-tdline+4(2) }/{ <fs_lines_read>-tdline+2(2) }|.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ELSE.

      SELECT SINGLE vbelv
        FROM vbfa
        INTO @DATA(lv_vbelv)
        WHERE vbeln   EQ @<fs_vbrp1>-vgbel
          AND posnn   EQ @<fs_vbrp1>-vgpos
          AND vbtyp_v EQ @is_vbrk-vbtyp.                "#EC CI_NOFIELD

      IF sy-subrc IS NOT INITIAL.
        SELECT SINGLE vbelv
          FROM vbfa
         WHERE vbeln   EQ @<fs_vbrp1>-vgbel
           AND posnn   EQ @<fs_vbrp1>-vgpos
           AND vbtyp_v EQ 'M'
          INTO @lv_vbelv.
      ENDIF.

      IF lv_vbelv IS INITIAL.
        SELECT SINGLE vbeln
          FROM vbfa
          INTO @lv_vbelv
          WHERE vbelv   EQ @<fs_vbrp1>-vbelv
            AND posnv   EQ @<fs_vbrp1>-posnv
            AND vbtyp_n EQ @is_vbrk-vbtyp.
      ENDIF.

      IF sy-subrc EQ 0.

        SELECT SINGLE a~nfenum, a~docdat
          FROM j_1bnfdoc AS a
          INNER JOIN j_1bnflin AS b ON a~docnum = b~docnum
          INTO ( @lv_nfenum, @lv_docdat )
          WHERE b~refkey EQ @lv_vbelv.

        IF sy-subrc EQ 0.

          lv_nfenum = |{ lv_nfenum ALPHA = OUT }|.

          CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
            EXPORTING
              input        = lv_docdat
            IMPORTING
              output       = lv_docdate
            EXCEPTIONS
              invalid_date = 1
              OTHERS       = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          ENDIF.

        ENDIF.
      ENDIF.

    ENDIF.

    IF is_vbrk-fkart EQ lc_fkart_yc62 OR
       is_vbrk-fkart EQ lc_fkart_ys62.
*  f55
      lv_texto = TEXT-f55.
      REPLACE '&1' IN lv_texto WITH lv_nfenum.
      REPLACE '&2' IN lv_texto WITH lv_docdate.

      IF lv_texto IS NOT INITIAL.

        CONDENSE lv_texto.

        CALL FUNCTION 'RKD_WORD_WRAP'
          EXPORTING
            textline            = lv_texto
            outputlen           = 72
          TABLES
            out_lines           = lt_out_lines
          EXCEPTIONS
            outputlen_too_large = 1
            OTHERS              = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
        ENDIF.

        lt_nfetx = <fs_nfetx_tab>.

        SORT lt_nfetx BY seqnum DESCENDING.

        lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
        lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

        LOOP AT lt_out_lines ASSIGNING FIELD-SYMBOL(<fs_out_lines>).
          ADD 1 TO lv_seq.
          IF <fs_nfetx_tab> IS ASSIGNED.
            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_out_lines> ) TO <fs_nfetx_tab>.
          ENDIF.
        ENDLOOP.

        cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.

        CLEAR: lv_texto,
               lv_linnum,
               lv_seq.

      ENDIF.
    ENDIF.

    IF is_vbrk-fkart EQ lc_fkart_yr62 OR
       is_vbrk-fkart EQ lc_fkart_yd62.
*  f56
      lv_texto = TEXT-f56.
      REPLACE '&1' IN lv_texto WITH lv_nfenum.
      REPLACE '&2' IN lv_texto WITH lv_docdate.

      IF lv_texto IS NOT INITIAL.

        CONDENSE lv_texto.

        CALL FUNCTION 'RKD_WORD_WRAP'
          EXPORTING
            textline            = lv_texto
            outputlen           = 72
          TABLES
            out_lines           = lt_out_lines
          EXCEPTIONS
            outputlen_too_large = 1
            OTHERS              = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
        ENDIF.

        lt_nfetx = <fs_nfetx_tab>.

        SORT lt_nfetx BY seqnum DESCENDING.

        lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
        lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

        LOOP AT lt_out_lines ASSIGNING <fs_out_lines>.
          ADD 1 TO lv_seq.
          IF <fs_nfetx_tab> IS ASSIGNED.
            APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_out_lines> ) TO <fs_nfetx_tab>.
          ENDIF.
        ENDLOOP.

        cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.

        CLEAR: lv_texto,
               lv_linnum,
               lv_seq.

      ENDIF.
    ELSE.

      IF is_vbrk-fkart EQ lc_fkart_z010.
*  f57
        lv_texto = TEXT-f57.
        REPLACE '&1' IN lv_texto WITH lv_nfenum.
        REPLACE '&2' IN lv_texto WITH lv_docdate.

        IF lv_texto IS NOT INITIAL.

          CONDENSE lv_texto.

          CALL FUNCTION 'RKD_WORD_WRAP'
            EXPORTING
              textline            = lv_texto
              outputlen           = 72
            TABLES
              out_lines           = lt_out_lines
            EXCEPTIONS
              outputlen_too_large = 1
              OTHERS              = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          ENDIF.

          lt_nfetx = <fs_nfetx_tab>.

          SORT lt_nfetx BY seqnum DESCENDING.

          lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
          lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

          LOOP AT lt_out_lines ASSIGNING <fs_out_lines>.
            ADD 1 TO lv_seq.
            IF <fs_nfetx_tab> IS ASSIGNED.
              APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_out_lines> ) TO <fs_nfetx_tab>.
            ENDIF.
          ENDLOOP.

          cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.

          CLEAR: lv_texto,
                 lv_linnum,
                 lv_seq.

        ENDIF.

        LOOP AT it_vbrp ASSIGNING <fs_vbrp>.
          ADD <fs_vbrp>-kzwi2 TO lv_sum_icms.
          ADD <fs_vbrp>-kzwi3 TO lv_sum_ipi.
          ADD <fs_vbrp>-kzwi4 TO lv_sum_icms_st.
        ENDLOOP.

        IF NOT lv_sum_icms IS INITIAL.
          WRITE lv_sum_icms TO lv_text_icms.
          CONDENSE lv_text_icms NO-GAPS.
          lv_text_icms = |ICMS { lv_text_icms }|.
        ENDIF.
        IF NOT lv_sum_icms_st IS INITIAL.
          WRITE lv_sum_icms_st TO lv_text_icms_st.
          CONDENSE lv_text_icms_st NO-GAPS.
          lv_text_icms_st = |ICMS ST { lv_text_icms_st }|.
        ENDIF.
        IF NOT lv_sum_ipi IS INITIAL.
          WRITE lv_sum_ipi TO lv_text_ipi.
          CONDENSE lv_text_ipi NO-GAPS.
          lv_text_ipi = |IPI { lv_text_ipi }|.
        ENDIF.

        lv_texto = |{ TEXT-f59 } { lv_text_icms } { lv_text_icms_st } { lv_text_ipi } |.
        CONDENSE lv_texto.

        IF lv_texto IS NOT INITIAL.

          REFRESH lt_out_lines.

          CALL FUNCTION 'RKD_WORD_WRAP'
            EXPORTING
              textline            = lv_texto
              outputlen           = 72
            TABLES
              out_lines           = lt_out_lines
            EXCEPTIONS
              outputlen_too_large = 1
              OTHERS              = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
          ENDIF.

          lt_nfetx = <fs_nfetx_tab>.

          SORT lt_nfetx BY seqnum DESCENDING.

          lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
          lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

          LOOP AT lt_out_lines ASSIGNING <fs_out_lines>.
            ADD 1 TO lv_seq.
            IF <fs_nfetx_tab> IS ASSIGNED.
              APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_out_lines> ) TO <fs_nfetx_tab>.
            ENDIF.
          ENDLOOP.

          cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.

          CLEAR: lv_texto,
                 lv_linnum,
                 lv_seq.

        ENDIF.

      ELSE.

        IF is_vbrk-fkart(2) EQ 'ZR' OR
           is_vbrk-fkart(2) EQ 'ZD' OR
           is_vbrk-fkart(2) EQ 'YR' OR
           is_vbrk-fkart(2) EQ 'YD'.
          lv_texto = TEXT-f58.

          IF is_vbrk-fkart EQ lc_fkart_yr65.
            CLEAR: lv_nfenum,
                   lv_docdat.
            SELECT SINGLE nfenum, docdat
              FROM j_1bnfdoc AS a
              INTO ( @lv_nfenum, @lv_docdat )
              WHERE docnum EQ @is_header-docref.
            IF sy-subrc EQ 0.
              lv_nfenum = |{ lv_nfenum ALPHA = OUT }|.
              CLEAR lv_docdate.
              CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
                EXPORTING
                  input        = lv_docdat
                IMPORTING
                  output       = lv_docdate
                EXCEPTIONS
                  invalid_date = 1
                  OTHERS       = 2.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
              ENDIF.
            ENDIF.
          ENDIF.

          REPLACE '&1' IN lv_texto WITH lv_nfenum.
          REPLACE '&2' IN lv_texto WITH lv_docdate.

* LSCHEPP - SD - 8000007651 - Mensagem ZD00 e YD00 - 23.05.2023 Início
          IF is_vbrk-fkart EQ lc_fkart_zd00 OR
             is_vbrk-fkart EQ lc_fkart_yd00.
            CLEAR: lv_nfenum,
                   lv_docdate,
                   lv_texto.
          ENDIF.
* LSCHEPP - SD - 8000007651 - Mensagem ZD00 e YD00 - 23.05.2023 Fim

          IF lv_texto IS NOT INITIAL.

            CONDENSE lv_texto.

            CALL FUNCTION 'RKD_WORD_WRAP'
              EXPORTING
                textline            = lv_texto
                outputlen           = 72
              TABLES
                out_lines           = lt_out_lines
              EXCEPTIONS
                outputlen_too_large = 1
                OTHERS              = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
            ENDIF.

            lt_nfetx = <fs_nfetx_tab>.

            SORT lt_nfetx BY seqnum DESCENDING.

            lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
            lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).

            LOOP AT lt_out_lines ASSIGNING <fs_out_lines>.
              ADD 1 TO lv_seq.
              IF <fs_nfetx_tab> IS ASSIGNED.
                APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_out_lines> ) TO <fs_nfetx_tab>.
              ENDIF.
            ENDLOOP.

            cs_header-infcpl = |{ cs_header-infcpl }  { lv_texto }|.

            CLEAR: lv_texto,
                   lv_linnum,
                   lv_seq.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.

*ENDIF.
