class ZCLSD_TRATA_CARACTER_ESPECIAL definition
  public
  final
  create public .

public section.

  methods EXECUTE
    importing
      !IV_TEXT type ANY
    returning
      value(RV_TEXT) type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZCLSD_TRATA_CARACTER_ESPECIAL IMPLEMENTATION.


  METHOD execute.

    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = iv_text
      IMPORTING
        outtext = rv_text.

    IF rv_text is INITIAL.
      rv_text = iv_text.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
