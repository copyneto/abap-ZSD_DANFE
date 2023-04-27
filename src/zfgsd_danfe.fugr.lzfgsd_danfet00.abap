*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSD_CST_B2B_OUT................................*
DATA:  BEGIN OF STATUS_ZTSD_CST_B2B_OUT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSD_CST_B2B_OUT              .
CONTROLS: TCTRL_ZTSD_CST_B2B_OUT
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZTSD_FORMAS_PAG.................................*
DATA:  BEGIN OF STATUS_ZTSD_FORMAS_PAG               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSD_FORMAS_PAG               .
CONTROLS: TCTRL_ZTSD_FORMAS_PAG
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZTSD_NFEFCPDANFE................................*
DATA:  BEGIN OF STATUS_ZTSD_NFEFCPDANFE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSD_NFEFCPDANFE              .
CONTROLS: TCTRL_ZTSD_NFEFCPDANFE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTSD_CST_B2B_OUT              .
TABLES: *ZTSD_FORMAS_PAG               .
TABLES: *ZTSD_NFEFCPDANFE              .
TABLES: ZTSD_CST_B2B_OUT               .
TABLES: ZTSD_FORMAS_PAG                .
TABLES: ZTSD_NFEFCPDANFE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
