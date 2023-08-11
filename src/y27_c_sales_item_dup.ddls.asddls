//@AbapCatalog.sqlViewName: 'Y27D_C_VBAP'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item'
@Metadata.allowExtensions: true
define view entity Y27_C_SALES_ITEM_dup as select from Y27_I_SALES_ITEM_dup
association to parent Y27_C_SALES_HEAD_dup as _soHead
on $projection.sales_doc_num = _soHead.sales_doc_num
{
    key sales_doc_num,
    key item_position,
    mat_num,
    mat_desc,
    unit_cost,
    total_item_cost,
    cost_currency,
    quanity,
    unit,
    last_changed,
    /* Associations */
    _soHead
}
