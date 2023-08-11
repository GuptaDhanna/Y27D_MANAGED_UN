CLASS lhc_Y27_C_SALES_HEAD DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR y27_c_sales_head RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE y27_c_sales_head.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE y27_c_sales_head.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE y27_c_sales_head.

    METHODS read FOR READ
      IMPORTING keys FOR READ y27_c_sales_head RESULT result.

    METHODS rba_Soitem FOR READ
      IMPORTING keys_rba FOR READ y27_c_sales_head\_Soitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_Soitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE y27_c_sales_head\_Soitem.

    METHODS blockOrder FOR MODIFY
      IMPORTING keys FOR ACTION soHead~blockOrder RESULT result.

    METHODS unblockOrder FOR MODIFY
      IMPORTING keys FOR ACTION soHead~unblockOrder RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR soHead RESULT result.

ENDCLASS.


CLASS lhc_Y27_C_SALES_HEAD IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA ls_so_head TYPE y27d_db_vbak.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_db_vbak.

    SELECT FROM y27d_db_vbak FIELDS MAX( vbeln ) INTO @DATA(lv_fin_vbeln).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      ls_so_head = CORRESPONDING #( <fs_entity> MAPPING
                  faksk = block_status
                  netwr = total_cost
                  spart = sales_div
                  vbeln = sales_doc_num
                  vkorg = sales_org
                  waerk = cost_currency
                  vtweg = sales_dist ).
      ls_so_head-erdat = sy-datum.
      ls_so_head-ernam = sy-uname.
      ls_so_head-vbeln = lv_fin_vbeln + 1.

      lv_fin_vbeln = ls_so_head-vbeln.

      APPEND ls_so_head TO lt_so_head.

      APPEND VALUE #( sales_doc_num = ls_so_head-vbeln
                      %msg          = NEW_message( id       = 'ZRAP_MSG_MANAGED'
                                                   number   = '001'
                                                   v1       = ls_so_head-vbeln
                                                   severity = if_abap_behv_message=>severity-success ) ) TO reported-sohead.

    ENDLOOP.

    y27d_cl_operation_un=>get_instance( )->buffer_so_head_create( it_so_h = lt_so_head ).

    READ ENTITIES OF y27_c_sales_head IN LOCAL MODE
         ENTITY soHead
         ALL FIELDS WITH CORRESPONDING #( lt_so_head )
         " TODO: variable is assigned but never used (ABAP cleaner)
         RESULT FINAL(headdata).
  ENDMETHOD.

  METHOD update.
    DATA ls_so_head TYPE y27d_db_vbak.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA ls_so_cont TYPE zif_structure=>ts_control.
    DATA lt_so_cont TYPE zif_structure=>tt_control.

    GET TIME STAMP FIELD FINAL(lv_time).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      ls_so_head = CORRESPONDING #( <fs_entity> MAPPING
                   erdat = date_created
                   ernam = person_created
                   faksk = block_status
                   netwr = total_cost
                   spart = sales_div
                   vbeln = sales_doc_num
                   vkorg = sales_org
                   waerk = cost_currency
                   vtweg = sales_dist ).
      ls_so_head-last_changed_timestamp = lv_time.

      APPEND ls_so_head TO lt_so_head.

      ls_so_cont = CORRESPONDING #( <fs_entity>-%control MAPPING
                                    erdat = date_created
                     ernam = person_created
                     faksk = block_status
                     netwr = total_cost
                     spart = sales_div
                     vbeln = sales_doc_num
                     vkorg = sales_org
                     waerk = cost_currency
                     vtweg = sales_dist
                     last_changed_timestamp = last_changed ).
      ls_so_cont-vbeln_id = ls_so_head-vbeln.
      APPEND ls_so_cont TO lt_so_cont.

    ENDLOOP.
    y27d_cl_operation_un=>get_instance( )->buffer_so_head_update( it_so_h = lt_so_head
                                                                  it_so_c = lt_so_cont ).
  ENDMETHOD.

  METHOD delete.
    DATA ls_so_head TYPE y27d_db_vbak.
    DATA ls_so_item TYPE y27d_db_vbap.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA lt_so_item TYPE STANDARD TABLE OF y27d_db_vbap.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      ls_so_head-vbeln = <fs_key>-sales_doc_num.
      ls_so_item-vbeln = <fs_key>-sales_doc_num.
      APPEND ls_so_head TO lt_so_head.
      APPEND ls_so_item TO lt_so_item.
    ENDLOOP.

    y27d_cl_operation_un=>get_instance( )->buffer_so_head_delete( it_so_h = lt_so_head
                                                                  it_so_i = lt_so_item ).
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Soitem.
  ENDMETHOD.

  METHOD cba_Soitem.
    DATA ls_item TYPE y27d_db_vbap.
    DATA lt_so_i TYPE STANDARD TABLE OF y27d_db_vbap.

    LOOP AT entities_cba INTO FINAL(ls_items).
      LOOP AT ls_items-%target INTO FINAL(ls_items_1).
        ls_item = CORRESPONDING #( ls_items_1
                        MAPPING arktx = mat_desc
                                kmein = unit
                                kpein = quanity
                                matnr = mat_num
                                last_changed_timestamp = last_changed
                                netpr = unit_cost
                                posnr = item_position
                                waerk = cost_currency ).
        ls_item-vbeln = ls_items-sales_doc_num.
        ls_item-netwr = ls_item-netpr * ls_item-kpein.
        APPEND ls_item TO lt_so_i.

        APPEND VALUE #( sales_doc_num = ls_item-vbeln
                        %msg          = NEW_message( id       = 'ZRAP_MSG_MANAGED'
                                                     number   = '001'
                                                     v1       = ls_item-vbeln
                                                     severity = if_abap_behv_message=>severity-information ) ) TO reported-soitem.

      ENDLOOP.
    ENDLOOP.

    y27d_cl_operation_un=>get_instance( )->buffer_so_item_create( it_so_i = lt_so_i ).

*    RESUME =
  ENDMETHOD.

  METHOD blockOrder.
    DATA lt_so_h TYPE STANDARD TABLE OF y27d_db_vbak.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_block>).

      lt_so_h = VALUE #( BASE lt_so_h
                         ( vbeln = <fs_block>-sales_doc_num
                           faksk = abap_true ) ).

    ENDLOOP.
    y27d_cl_operation_un=>get_instance( )->buffer_so_order_block( it_so_h = lt_so_h
                                                                  iv_para = 'X' ).
    result = VALUE #( FOR ls_so_h1 IN lt_so_h
                      ( sales_doc_num           = ls_so_h1-vbeln
                        %param-sales_doc_num    = ls_so_h1-vbeln
                        %param-block_status_msg = ls_so_h1-faksk ) ).
  ENDMETHOD.

  METHOD unblockOrder.
    DATA lt_so_h TYPE STANDARD TABLE OF y27d_db_vbak.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_block>).

      lt_so_h = VALUE #( BASE lt_so_h
                         ( vbeln = <fs_block>-sales_doc_num
                           faksk = abap_true ) ).

    ENDLOOP.
    y27d_cl_operation_un=>get_instance( )->buffer_so_order_block( it_so_h = lt_so_h
                                                                  iv_para = ' ' ).
    result = VALUE #( FOR ls_so_h1 IN lt_so_h
                      ( sales_doc_num           = ls_so_h1-vbeln
                        %param-sales_doc_num    = ls_so_h1-vbeln
                        %param-block_status_msg = ls_so_h1-faksk ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    DATA lt_result LIKE LINE OF result.

    SELECT * FROM y27d_db_vbak
    FOR ALL ENTRIES IN @keys
    WHERE vbeln = @keys-sales_doc_num
    INTO TABLE @FINAL(lt_so_head).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_so_head ASSIGNING FIELD-SYMBOL(<fs_so_head>).
      lt_REsult = VALUE #( sales_doc_num        = <fs_so_head>-vbeln

                           %update              = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %delete              = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %assoc-_soItem       = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %action-blockOrder   = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-o-disabled
                                                          ELSE if_abap_behv=>fc-o-enabled )

                           %action-unblockOrder = COND #( WHEN <fs_so_head>-faksk = 'X'
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          ELSE if_abap_behv=>fc-o-disabled ) ).

      APPEND lt_result TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_Y27_C_SALES_ITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE y27_c_sales_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE y27_c_sales_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ y27_c_sales_item RESULT result.

    METHODS rba_Sohead FOR READ
      IMPORTING keys_rba FOR READ y27_c_sales_item\_Sohead FULL result_requested RESULT result LINK association_links.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE soItem.
*    METHODS determineTotalPrice FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR soItem~determineTotalPrice.

*    METHODS determineTotalPrice FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR soItem~determineTotalPrice.

ENDCLASS.


CLASS lhc_Y27_C_SALES_ITEM IMPLEMENTATION.
  METHOD update.
    DATA ls_so_item TYPE y27d_db_vbap.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_so_head TYPE y27d_db_vbak.
    DATA lt_so_item TYPE STANDARD TABLE OF y27d_db_vbap.
    DATA ls_so_cont TYPE zif_structure=>ts_control_it.
    DATA lt_so_cont TYPE zif_structure=>tt_control_item.

    GET TIME STAMP FIELD FINAL(lv_time).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).

      ls_so_item = CORRESPONDING #( <fs_entity> MAPPING
                   arktx = mat_desc
                   kmein = unit
                   kpein = quanity
                   matnr = mat_num
                   netpr = unit_cost
                   netwr = total_item_cost
                   posnr = item_position
                   vbeln = sales_doc_num
                   waerk = cost_currency ).
      ls_so_head-last_changed_timestamp = lv_time.

      APPEND ls_so_item TO lt_so_item.

      ls_so_cont = CORRESPONDING #( <fs_entity>-%control MAPPING
                                   arktx = mat_desc
                   kmein = unit
                   kpein = quanity
                   matnr = mat_num
                   netpr = unit_cost
                   netwr = total_item_cost
                   posnr = item_position
                   vbeln = sales_doc_num
                   waerk = cost_currency ).
      ls_so_cont-vbeln_id = ls_so_item-vbeln.
      ls_so_cont-posnr_id = ls_so_item-posnr.
      APPEND ls_so_cont TO lt_so_cont.

    ENDLOOP.
    y27d_cl_operation_un=>get_instance( )->buffer_so_item_update( it_so_i = lt_so_item
                                                                  it_so_c = lt_so_cont ).
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Sohead.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

*  METHOD determineTotalPrice.
*
*  ENDMETHOD.

ENDCLASS.


CLASS lsc_Y27_C_SALES_HEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save              REDEFINITION.

    METHODS cleanup           REDEFINITION.

    METHODS cleanup_finalize  REDEFINITION.

ENDCLASS.


CLASS lsc_Y27_C_SALES_HEAD IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    y27d_cl_operation_un=>get_instance( )->save( ).
  ENDMETHOD.

  METHOD cleanup.
    y27d_cl_operation_un=>get_instance( )->clean_up( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
