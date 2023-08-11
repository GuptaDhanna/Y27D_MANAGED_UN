@AbapCatalog.sqlViewName: 'Y27D_V_VBAP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item'
define view Y27_I_SALES_ITEM as select from y27d_db_vbap
association[1..1] to Y27_I_SALES_HEAD as _soHead
on $projection.sales_doc_num = _soHead.sales_doc_num
{
   key vbeln as sales_doc_num,
    key posnr as item_position,
    matnr as mat_num,
    
    @Semantics.text: true
    arktx as mat_desc,
    
    @Semantics.amount.currencyCode: 'cost_currency'
    netpr as unit_cost,
    
    @Semantics.amount.currencyCode: 'cost_currency'
    netwr as total_item_cost,
    waerk as cost_currency,
    
    @Semantics.quantity.unitOfMeasure: 'unit'
    kpein as quanity,
    kmein as unit,
    
    @Semantics.systemDateTime.createdAt: true
    last_changed_timestamp as last_changed,
    
    _soHead
}
