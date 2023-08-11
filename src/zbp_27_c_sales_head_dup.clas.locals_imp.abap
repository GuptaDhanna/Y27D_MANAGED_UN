CLASS lsc_y27_c_sales_head_dup DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_y27_c_sales_head_dup IMPLEMENTATION.

  METHOD save_modified.

    DATA ls_so_head TYPE y27d_db_vbak.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_db_vbak.
    SELECT FROM y27d_db_vbak FIELDS MAX( vbeln ) INTO @DATA(lv_fin_vbeln).
    GET TIME STAMP FIELD FINAL(lv_time_stamp).
    IF create-sohead IS NOT INITIAL.
      MODIFY y27d_db_vbak FROM TABLE @( VALUE #( FOR ls_so IN create-sohead
                            LET ls_final = VALUE y27d_db_vbak( erdat = sy-datum
                                                               ernam = sy-uname
                                                               vbeln = lv_fin_vbeln + 1  )
                            IN (  CORRESPONDING #( BASE ( ls_final ) ls_so MAPPING
                                                             vkorg = sales_org
                                                             vtweg = sales_dist
                                                             spart = sales_div
                                                             waerk = cost_currency
                                                             faksk = block_status
                                                             netwr = total_cost
                                                     EXCEPT vbeln erdat ernam ) ) ) ).
    ENDIF.
    IF update-sohead IS NOT INITIAL.
    DATA ls_so_cont TYPE zif_structure=>ts_control.
    DATA lt_so_cont TYPE zif_structure=>tt_control.

    GET TIME STAMP FIELD FINAL(lv_time).
    LOOP AT update-sohead ASSIGNING FIELD-SYMBOL(<fs_entity>).

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


    ENDIF.
    IF delete IS NOT INITIAL.
      DATA: lr_so_doc TYPE RANGE OF y27d_db_vbak-vbeln.
      lr_so_doc = VALUE #( BASE lr_so_doc FOR ls_sohead IN delete-sohead
                           ( sign = 'I' option ='EQ' low = ls_sohead-sales_doc_num )  ).

      DELETE FROM y27d_db_vbak WHERE vbeln IN @lr_so_doc.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_y27_c_sales_item_dup DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS determineTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Y27_C_SALES_ITEM_dup~determineTotalPrice.
    METHODS determineHTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR soItem~determineHTotalPrice.

ENDCLASS.

CLASS lhc_y27_c_sales_item_dup IMPLEMENTATION.

  METHOD determineTotalPrice.

    READ ENTITIES OF y27_c_sales_head_dup IN LOCAL MODE
    ENTITY soItem
    FIELDS ( quanity ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_so_item).
    IF lt_so_item IS NOT INITIAL.
      LOOP AT lt_so_item ASSIGNING FIELD-SYMBOL(<fs_so_item>).
        MODIFY ENTITIES OF Y27_C_SALES_HEAD_dup IN LOCAL MODE
     ENTITY soItem
     UPDATE
     FIELDS ( total_item_cost  ) WITH VALUE #( ( %tky = <fs_so_item>-%tky
                                                 total_item_cost = <fs_so_item>-unit_cost * <fs_so_item>-quanity  ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD determineHTotalPrice.

    READ ENTITIES OF y27_c_sales_head_dup IN LOCAL MODE
      ENTITY soItem
      FIELDS ( total_item_cost ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_so_item).
    IF lt_so_item IS NOT INITIAL.
      LOOP AT lt_so_item ASSIGNING FIELD-SYMBOL(<fs_so_item>).
        MODIFY ENTITIES OF Y27_C_SALES_HEAD_dup IN LOCAL MODE
     ENTITY Sohead
     UPDATE
     FIELDS ( total_cost ) WITH VALUE #( ( %tky = <fs_so_item>-%tky
                                       total_cost = REDUCE #( INIT lv_cost = 0
                                                 FOR ls_so IN lt_so_item
                                                 WHERE ( sales_doc_num = <fs_so_item>-sales_doc_num )
                                                 NEXT lv_cost = lv_cost + <fs_so_item>-total_item_cost ) ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Y27_C_SALES_HEAD_dup DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Y27_C_SALES_HEAD_dup RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR y27_c_sales_head_dup RESULT result.

    METHODS blockorder FOR MODIFY
      IMPORTING keys FOR ACTION y27_c_sales_head_dup~blockorder RESULT result.

    METHODS unblockorder FOR MODIFY
      IMPORTING keys FOR ACTION y27_c_sales_head_dup~unblockorder RESULT result.

ENDCLASS.

CLASS lhc_Y27_C_SALES_HEAD_dup IMPLEMENTATION.

  METHOD get_instance_authorizations.
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

                           %update             = COND #( WHEN <fs_so_head>-faksk = 'X'
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

ENDCLASS.
