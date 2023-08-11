@AbapCatalog.sqlViewName: 'Y27_V_VBAK_DU'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Head'
define root view Y27_I_SALES_HEAD_DUP as select from y27d_db_vbak
association [0..*] to Y27_I_SALES_ITEM_DUP as _soItem
on $projection.sales_doc_num = _soItem.sales_doc_num
{
    key vbeln as sales_doc_num,
    erdat as date_created,
    
    @Semantics.user.createdBy: true
    ernam as person_created,
    vkorg as sales_org,
    vtweg as sales_dist,
    spart as sales_div,
    @Semantics.amount.currencyCode: 'cost_currency'
    netwr as total_cost,
    waerk as cost_currency,
    faksk as block_status,
    
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_timestamp as last_changed,
    
    _soItem
}
