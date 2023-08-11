INTERFACE zif_structure
  PUBLIC .

  TYPES: BEGIN OF ts_control,
         vbeln_id TYPE zvbeln,
         vbeln TYPE abp_behv_flag,
         erdat  TYPE abp_behv_flag,
  ernam  TYPE abp_behv_flag,
  vkorg   TYPE abp_behv_flag,
  vtweg   TYPE abp_behv_flag,
  spart   TYPE abp_behv_flag,
  netwr   TYPE abp_behv_flag,
  waerk    TYPE abp_behv_flag,
  faksk    TYPE abp_behv_flag,
  last_changed_timestamp  TYPE abp_behv_flag,
  END OF TS_CONTROL,
  tt_control TYPE TABLE OF ts_control.

  TYPES: BEGIN OF ts_control_it,
         vbeln_id TYPE zvbeln,
         posnr_id TYPE y27d_db_vbap-posnr,
         vbeln    TYPE abp_behv_flag,
         posnr    TYPE abp_behv_flag,
  matnr           TYPE abp_behv_flag,
  arktx           TYPE abp_behv_flag,
  netpr           TYPE abp_behv_flag,
  netwr           TYPE abp_behv_flag,
  waerk           TYPE abp_behv_flag,
  kpein           TYPE abp_behv_flag,
  kmein           TYPE abp_behv_flag,
  last_changed_timestamp TYPE abp_behv_flag,
  END OF ts_control_it,
  tt_control_item TYPE TABLE OF ts_control_it.

ENDINTERFACE.
