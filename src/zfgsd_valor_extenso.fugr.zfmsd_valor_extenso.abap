FUNCTION zfmsd_valor_extenso.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_VALOR) TYPE  CHAR100
*"  EXPORTING
*"     REFERENCE(EV_VALOR) TYPE  STRING
*"----------------------------------------------------------------------
  DATA ls_words TYPE spell.


  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      amount    = iv_valor
      currency  = 'BRL'
      language  = sy-langu
    IMPORTING
      in_words  = ls_words
    EXCEPTIONS
      not_found = 1
      too_large = 2
      OTHERS    = 3.

  IF sy-subrc = 0.

    IF ls_words-word CS '100'.
      IF ls_words-word CS '100 E'.
        REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
      ELSE.
        REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
      ENDIF.
      IF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '200'.
      REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '300'.
      REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '400'.
      REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '500'.
      REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '600'.
      REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '700'.
      REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '800'.
      REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '900'.
        REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      ENDIF.
    ELSEIF ls_words-word CS '900'.
      REPLACE ALL OCCURRENCES OF '900' IN ls_words-word WITH 'NOVECENTOS'.
      IF ls_words-word CS '100'.
        IF ls_words-word CS '100 E'.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CENTO'.
        ELSE.
          REPLACE ALL OCCURRENCES OF '100' IN ls_words-word WITH 'CEM'.
        ENDIF.
      ELSEIF ls_words-word CS '200'.
        REPLACE ALL OCCURRENCES OF '200' IN ls_words-word WITH 'DUZENTOS'.
      ELSEIF ls_words-word CS '300'.
        REPLACE ALL OCCURRENCES OF '300' IN ls_words-word WITH 'TREZENTOS'.
      ELSEIF ls_words-word CS '400'.
        REPLACE ALL OCCURRENCES OF '400' IN ls_words-word WITH 'QUATROCENTOS'.
      ELSEIF ls_words-word CS '500'.
        REPLACE ALL OCCURRENCES OF '500' IN ls_words-word WITH 'QUINHENTOS'.
      ELSEIF ls_words-word CS '600'.
        REPLACE ALL OCCURRENCES OF '600' IN ls_words-word WITH 'SEISCENTOS'.
      ELSEIF ls_words-word CS '700'.
        REPLACE ALL OCCURRENCES OF '700' IN ls_words-word WITH 'SETECENTOS'.
      ELSEIF ls_words-word CS '800'.
        REPLACE ALL OCCURRENCES OF '800' IN ls_words-word WITH 'OITOCENTOS'.
      ENDIF.
    ENDIF.

    IF ls_words-decword IS INITIAL OR
       ls_words-decword EQ 'ZERO'.
      SEARCH ls_words-word FOR 'MILHÃO'.
      IF sy-subrc EQ 0.
        SPLIT ls_words-word AT space INTO DATA(lv_var1) DATA(lv_var2).
        IF lv_var1 NE 'UM'.
          REPLACE ALL OCCURRENCES OF 'MILHÃO' IN ls_words-word WITH 'MILHÕES DE'.
        ENDIF.
      ENDIF.
      ev_valor = |{ ls_words-word } REAIS|.
    ELSE.
      ev_valor = |{ ls_words-word } REAIS E { ls_words-decword } CENTAVOS|.
    ENDIF.

    REPLACE ALL OCCURRENCES OF 'UMMIL' IN ev_valor WITH 'UM MIL'.
    REPLACE ALL OCCURRENCES OF 'DOISMIL' IN ev_valor WITH 'DOIS MIL'.
    REPLACE ALL OCCURRENCES OF 'TRÊSMIL' IN ev_valor WITH 'TRÊS MIL'.
    REPLACE ALL OCCURRENCES OF 'QUATROMIL' IN ev_valor WITH 'QUATRO MIL'.
    REPLACE ALL OCCURRENCES OF 'CINCOMIL' IN ev_valor WITH 'CINCO MIL'.
    REPLACE ALL OCCURRENCES OF 'SEISMIL' IN ev_valor WITH 'SEIS MIL'.
    REPLACE ALL OCCURRENCES OF 'SETEMIL' IN ev_valor WITH 'SETE MIL'.
    REPLACE ALL OCCURRENCES OF 'OITOMIL' IN ev_valor WITH 'OITO MIL'.
    REPLACE ALL OCCURRENCES OF 'NOVEMIL' IN ev_valor WITH 'NOVE MIL'.

  ENDIF.

ENDFUNCTION.
