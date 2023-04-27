*&---------------------------------------------------------------------*
*& Include          ZSDI_ADD_LOCAL_NEGOCIOS
*&---------------------------------------------------------------------*
   IF ls_lin-reftyp = gc_fat AND is_header-direct = 2 .

     SELECT SINGLE low
       INTO @DATA(lv_param)
       FROM ztca_param_val
       WHERE modulo = @lc_modulo
         AND chave1 = @lc_chv1
         AND chave2 = @lc_chv2.
     IF lv_param = is_header-branch.

       lv_name = is_header-branch.

       CALL FUNCTION 'READ_TEXT'
         EXPORTING
           id                      = 'CNFE'
           language                = sy-langu
           name                    = lv_name
           object                  = 'TEXT'
         TABLES
           lines                   = lt_lines
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

         IF <fs_nfetx_tab> IS ASSIGNED.
           lt_nfetx = <fs_nfetx_tab>.
           SORT lt_nfetx BY seqnum DESCENDING.
         ENDIF.

         LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<fs_line>).

           IF <fs_line>-tdline IS INITIAL.
             CONTINUE.
           ENDIF.

           lv_seq = VALUE #( lt_nfetx[ 1 ]-seqnum DEFAULT 0 ).
           lv_linnum = VALUE #( lt_nfetx[ 1 ]-linnum DEFAULT 0 ).


           ADD 1 TO lv_seq.
           IF <fs_nfetx_tab> IS ASSIGNED.
             APPEND VALUE j_1bnfftx( seqnum = lv_seq linnum = lv_linnum message = <fs_line>-tdline ) TO <fs_nfetx_tab>.
             cs_header-infcpl = |{ cs_header-infcpl }  { <fs_line>-tdline }|.
           ENDIF.

         ENDLOOP.
       ENDIF.
     ENDIF.
   ENDIF.
