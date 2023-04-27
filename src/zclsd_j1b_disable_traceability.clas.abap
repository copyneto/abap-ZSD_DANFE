class ZCLSD_J1B_DISABLE_TRACEABILITY definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_BADI_J1B_TRACEABILITY .
protected section.
private section.
ENDCLASS.



CLASS ZCLSD_J1B_DISABLE_TRACEABILITY IMPLEMENTATION.


  METHOD IF_EX_BADI_J1B_TRACEABILITY~DISABLE_TRACEABILITY_FILLING.

*   According to the Technical Note 2016.002 v1.60
*   Traceability Data (Group I80) Filling is mandatory only for specific industries.
*   This BAdI gives you the option to deactivate its filling during Billing Creation for SD processes.
*   To do so, just set the value of NFeTrcblyFillingIsDisabled to TRUE.

    NFeTrcblyFillingIsDisabled = abap_true.

  ENDMETHOD.
ENDCLASS.
