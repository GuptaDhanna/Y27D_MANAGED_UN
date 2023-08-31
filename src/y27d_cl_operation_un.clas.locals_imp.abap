*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS y27d_cl_buffer DEFINITION FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES tt_soh TYPE STANDARD TABLE OF y27d_db_vbak.
    TYPES tt_soi TYPE STANDARD TABLE OF y27d_db_vbap.

    DATA tSOH_upd TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA tSOH_cre TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA tSOI_upd TYPE STANDARD TABLE OF y27d_db_vbap.
    DATA tSOI_cre TYPE STANDARD TABLE OF y27d_db_vbap.
    DATA tSOI_del TYPE STANDARD TABLE OF y27d_db_vbap.
    DATA tSOH_del TYPE STANDARD TABLE OF y27d_db_vbak.

    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO y27d_cl_buffer.

    METHODS buffer_so_head_delete IMPORTING it_so_head TYPE tt_soh
                                            it_so_item TYPE tt_soi.

    METHODS buffer_so_head_create IMPORTING it_so_head TYPE tt_soh.
    METHODS buffer_so_item_create IMPORTING it_so_item TYPE tt_soi.

    METHODS buffer_so_head_update IMPORTING it_so_head TYPE tt_soh
                                            it_so_cont TYPE zif_structure=>tt_control
                                            iv_x       TYPE char1 OPTIONAL.

    METHODS buffer_so_item_update IMPORTING it_so_item TYPE tt_soi
                                            it_so_cont TYPE zif_structure=>tt_control_item.

    METHODS buffer_so_order_block IMPORTING it_so_h TYPE tt_soh
                                            iv_para TYPE char2.

    METHODS buffer_order_unblock IMPORTING it_so_h TYPE tt_soh
                                           iv_para TYPE char2.

    METHODS save.
    METHODS clean_up.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO y27d_cl_buffer.
ENDCLASS.


CLASS y27d_cl_buffer IMPLEMENTATION.
  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.

  " Delete Method
  METHOD buffer_so_head_delete.
    MOVE-CORRESPONDING it_so_head TO tsoh_del.
  ENDMETHOD.

  METHOD clean_up.
    CLEAR: tsoh_upd,
           tsoh_del,
           tsoh_cre,
           tsoi_upd.
  ENDMETHOD.

  METHOD save.
    DELETE y27d_db_vbak FROM TABLE @tsoh_del.
    DELETE y27d_db_vbap FROM TABLE @tsoi_del.
    UPDATE y27d_db_vbak FROM TABLE @tsoh_upd.
    MODIFY y27d_db_vbak FROM TABLE @tsoh_cre.
    MODIFY y27d_db_vbap FROM TABLE @tsoi_cre.
    MODIFY y27d_db_vbap FROM TABLE @tsoi_upd.
  ENDMETHOD.

  METHOD buffer_so_head_create.
    MOVE-CORRESPONDING it_so_head TO tsoh_cre.
  ENDMETHOD.

  METHOD buffer_so_head_update.
    DATA lv_flag_cont TYPE i VALUE 2.
    DATA lr_struc_des TYPE REF TO cl_abap_structdescr.
    DATA lt_struc_des TYPE abap_component_tab.
    DATA l_component  TYPE LINE OF abap_component_tab.

    GET TIME STAMP FIELD FINAL(lv_time_stamp).
    " Get Data from Actual Table
    IF it_so_head IS NOT INITIAL.
      SELECT * FROM y27d_db_vbak
     FOR ALL ENTRIES IN @it_so_head
     WHERE vbeln = @it_so_head-vbeln
     INTO TABLE @DATA(lt_so_all).
    ENDIF.

    LOOP AT lt_so_all ASSIGNING FIELD-SYMBOL(<fs_so_all>).
      READ TABLE it_so_head ASSIGNING FIELD-SYMBOL(<fs_so_head>) WITH KEY vbeln = <fs_so_all>-vbeln.
      IF sy-subrc = 0.

        READ TABLE it_so_cont ASSIGNING FIELD-SYMBOL(<fs_so_cntrl>) WITH KEY vbeln_id = <fs_so_head>-vbeln.
        IF sy-subrc = 0.
          IF lt_struc_des IS INITIAL.
            lr_struc_des ?= cl_abap_typedescr=>describe_by_data( <fs_so_cntrl> ).
            lt_struc_des = lr_struc_des->get_components( ).
          ENDIF.

          DO.

            ASSIGN COMPONENT lv_flag_cont OF STRUCTURE <fs_so_cntrl> TO FIELD-SYMBOL(<lv_flag>).
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.

            IF <lv_flag> = 01 OR <lv_flag> = 1.
              READ TABLE lt_struc_des INTO l_component INDEX lv_flag_cont.
              ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_so_all> TO FIELD-SYMBOL(<fs_db>).
              ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_so_head> TO FIELD-SYMBOL(<fs_upd>).
              IF l_component-name EQ 'FAKSK'.
                IF <fs_upd> EQ 1.
                  ASSIGN abap_true TO <fs_upd>.
                ELSEIF <fs_upd> EQ 3.
                  ASSIGN abap_false TO <fs_upd>.
                ENDIF.
              ENDIF.

              <fs_db> = <fs_upd>.
              <fs_so_all>-last_changed_timestamp = lv_time_stamp.
            ENDIF.
            lv_flag_cont += 1.
          ENDDO.
        ENDIF.
      ENDIF.

      APPEND <fs_so_all> TO tsoh_upd.
    ENDLOOP.
  ENDMETHOD.

  METHOD buffer_so_order_block.
    LOOP AT it_so_h INTO DATA(ls_so_h).
      UPDATE y27d_db_vbak  SET faksk = @iv_para
        WHERE vbeln = @ls_so_h-vbeln.
    ENDLOOP.
  ENDMETHOD.

  METHOD buffer_order_unblock.
    LOOP AT it_so_h INTO DATA(ls_so_h).
      UPDATE y27d_db_vbak  SET faksk = @iv_para
        WHERE vbeln = @ls_so_h-vbeln.
    ENDLOOP.
  ENDMETHOD.

  METHOD buffer_so_item_create.
    tsoi_cre = CORRESPONDING #( it_so_item ).
  ENDMETHOD.

  METHOD buffer_so_item_update.
    DATA lv_flag_cont TYPE i VALUE 2.
*    DATA lr_struc_des TYPE REF TO cl_abap_structdescr.
    DATA: lt_struc_des TYPE abap_component_tab.
*          lo_table TYPE REF TO cl_abap_tabledescr.
    DATA l_component  TYPE LINE OF abap_component_tab.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    " Get Data from Actual Table
    IF it_so_item IS NOT INITIAL.
      SELECT * FROM y27d_db_vbap
     FOR ALL ENTRIES IN @it_so_item
     WHERE vbeln = @it_so_item-vbeln
     INTO TABLE @DATA(lt_so_all).
      IF sy-subrc = 0.
        SORT lt_so_all BY vbeln
                          posnr.
      ENDIF.
    ENDIF.

    LOOP AT lt_so_all ASSIGNING FIELD-SYMBOL(<fs_so_all>).
      READ TABLE it_so_item ASSIGNING FIELD-SYMBOL(<fs_so_head>) WITH KEY vbeln = <fs_so_all>-vbeln
                                                                          posnr = <fs_so_all>-posnr.
      IF sy-subrc = 0.

        READ TABLE it_so_cont ASSIGNING FIELD-SYMBOL(<fs_so_cntrl>) WITH KEY vbeln_id = <fs_so_head>-vbeln
                                                                             posnr_id = <fs_so_head>-posnr.
        IF sy-subrc = 0.
*          IF lt_struc_des IS INITIAL.
          DATA(lo_table) = CAST cl_abap_structdescr(
                                cl_abap_typedescr=>describe_by_data( <fs_so_cntrl> ) ).

*            lt_struc_des = lr_struc_des->get_components( ).
          lt_struc_des = lo_table->get_components(  ).
*          ENDIF.

          DO.

            ASSIGN COMPONENT lv_flag_cont OF STRUCTURE <fs_so_cntrl> TO FIELD-SYMBOL(<lv_flag>).
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.

            IF <lv_flag> = 01 OR <lv_flag> = 1.
              READ TABLE lt_struc_des INTO l_component INDEX lv_flag_cont.
              ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_so_all> TO FIELD-SYMBOL(<fs_db>).
              ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_so_head> TO FIELD-SYMBOL(<fs_upd>).

              <fs_db> = <fs_upd>.
              IF     <fs_so_cntrl>-kpein IS NOT INITIAL
                 AND <fs_so_cntrl>-netpr IS NOT INITIAL.

                <fs_so_all>-netwr = <fs_so_head>-kpein * <fs_so_head>-netpr.
              ELSEIF <fs_so_cntrl>-kpein IS NOT INITIAL.
                <fs_so_all>-netwr = <fs_so_head>-kpein * <fs_so_all>-netpr.
              ELSEIF <fs_so_cntrl>-netpr IS NOT INITIAL.
                <fs_so_all>-netwr = <fs_so_all>-kpein * <fs_so_head>-netpr.
              ENDIF.
              <fs_so_all>-last_changed_timestamp = lv_time_stamp.
            ENDIF.
            lv_flag_cont += 1.
          ENDDO.
        ENDIF.
      ENDIF.
      APPEND <fs_so_all> TO tsoi_upd.

    ENDLOOP.
    IF tsoi_upd IS NOT INITIAL.
      DATA lv_total TYPE y27d_db_vbak-netwr.
      SELECT * FROM y27d_db_vbak
      FOR ALL ENTRIES IN @tsoi_upd
      WHERE vbeln = @tsoi_upd-vbeln
      INTO TABLE @DATA(lt_head).
      IF sy-subrc = 0.
        LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
          " TODO: variable is assigned but never used (ABAP cleaner)
          READ TABLE tsoi_upd ASSIGNING FIELD-SYMBOL(<fs_upd1>) WITH KEY vbeln = <fs_head>-vbeln.
          IF sy-subrc = 0.
            DATA(lv_tabix) = sy-tabix.
            LOOP AT tsoi_upd ASSIGNING FIELD-SYMBOL(<fs_item>) FROM lv_tabix.
              IF <fs_item>-vbeln <> <fs_head>-vbeln.
                EXIT.
              ENDIF.
              lv_total += <fs_item>-netwr.
            ENDLOOP.
            <fs_head>-netwr = lv_total.
            CLEAR lv_total.
          ENDIF.
        ENDLOOP.
        APPEND LINES OF lt_head TO tsoh_upd.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
