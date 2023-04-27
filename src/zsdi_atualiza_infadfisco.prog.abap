*&---------------------------------------------------------------------*
*& Include          ZSDI_ATUALIZA_INFADFISCO
*&---------------------------------------------------------------------*
   IF lv_infadfisco IS NOT INITIAL.

     lo_logbr_texts = lo_logbr_factory->create( ).

     IF lo_logbr_texts IS BOUND.
       cs_header-infadfisco = lo_logbr_texts->get_infadfisco( iv_docnum = is_header-docnum ).
     ENDIF.

     SEARCH cs_header-infadfisco FOR lv_infadfisco.
     IF sy-subrc NE 0.
       cs_header-infadfisco = |{ cs_header-infadfisco }{ lv_infadfisco }{ '&' }|.
       CONDENSE cs_header-infadfisco.
     ENDIF.

   ENDIF.
