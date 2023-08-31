CLASS zcl_test_gupta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS select.
ENDCLASS.



CLASS ZCL_TEST_GUPTA IMPLEMENTATION.


  METHOD select.
    DATA lt_material  TYPE STANDARD TABLE OF y27d_db_vbak.
    DATA lt_constants TYPE STANDARD TABLE OF zconstants.

    LOOP AT lt_material ASSIGNING FIELD-SYMBOL(<fs_material>).

      LOOP AT lt_constants ASSIGNING FIELD-SYMBOL(<fs_constants>).
        SPLIT <fs_constants>-value AT '/' INTO FINAL(lv_mtart) FINAL(lv_matkl).
        IF    <fs_material>-vkorg CP lv_matkl
           OR <fs_material>-vkorg  = lv_matkl.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
