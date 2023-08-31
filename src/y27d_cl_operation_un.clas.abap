CLASS y27d_cl_operation_un DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_soh TYPE STANDARD TABLE OF y27d_db_vbak.
    TYPES tt_soi TYPE STANDARD TABLE OF y27d_db_vbap.

    DATA tSOH_upd TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA tSOI_upd TYPE STANDARD TABLE OF y27d_db_vbap.
    DATA tSOH_del TYPE STANDARD TABLE OF y27d_db_vbak.

    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO y27d_cl_operation_un.

    METHODS buffer_so_head_delete IMPORTING it_so_h TYPE tt_soh
                                            it_so_i TYPE tt_soi.

    METHODS buffer_so_head_create IMPORTING it_so_h TYPE tt_soh.
    METHODS buffer_so_item_create IMPORTING it_so_i TYPE tt_soi.

    METHODS buffer_so_head_update IMPORTING it_so_h TYPE tt_soh
                                            it_so_c TYPE zif_structure=>tt_control.

    METHODS buffer_so_item_update IMPORTING it_so_i TYPE tt_soi
                                            it_so_c TYPE zif_structure=>tt_control_item.

    METHODS buffer_so_order_block IMPORTING it_so_h TYPE tt_soh
                                            iv_para TYPE char2.

    METHODS buffer_order_unblock IMPORTING it_so_h TYPE tt_soh
                                           iv_para TYPE char2.

    METHODS save.
    METHODS clean_up.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO y27d_cl_operation_un.
ENDCLASS.



CLASS Y27D_CL_OPERATION_UN IMPLEMENTATION.


  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    ro_instance = go_instance.
  ENDMETHOD.


  METHOD buffer_so_head_delete.
    y27d_cl_buffer=>get_instance( )->buffer_so_head_delete( it_so_head = it_so_h
                                                            it_so_item = it_so_i ).
  ENDMETHOD.


  METHOD clean_up.
    y27d_cl_buffer=>get_instance( )->clean_up( ).
  ENDMETHOD.


  METHOD save.
    y27d_cl_buffer=>get_instance( )->save( ).
  ENDMETHOD.


  METHOD buffer_so_head_create.
    y27d_cl_buffer=>get_instance( )->buffer_so_head_create( it_so_head = it_so_h ).
  ENDMETHOD.


  METHOD buffer_so_head_update.
    y27d_cl_buffer=>get_instance( )->buffer_so_head_update( it_so_head = it_so_h
                                                            it_so_cont = it_so_c ).
  ENDMETHOD.


  METHOD buffer_so_item_update.
    y27d_cl_buffer=>get_instance( )->buffer_so_item_update( it_so_item = it_so_i
                                                            it_so_cont = it_so_c ).
  ENDMETHOD.


  METHOD buffer_so_order_block.
    y27d_cl_buffer=>get_instance( )->buffer_so_order_block( it_so_h = it_so_h
                                                            iv_para = iv_para ).
  ENDMETHOD.


  METHOD buffer_order_unblock.
    y27d_cl_buffer=>get_instance( )->buffer_so_order_block( it_so_h = it_so_h
                                                            iv_para = iv_para ).
  ENDMETHOD.


  METHOD buffer_so_item_create.
    y27d_cl_buffer=>get_instance( )->buffer_so_item_create( it_so_item = it_so_i  ).
  ENDMETHOD.
ENDCLASS.
