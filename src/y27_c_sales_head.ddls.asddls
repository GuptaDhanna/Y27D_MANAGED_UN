//@AbapCatalog.sqlViewName: 'Y27D_C_VBAK'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View of Sales Header'
@Metadata.allowExtensions: true
define root view entity Y27_C_SALES_HEAD as select from Y27_I_SALES_HEAD
composition[0..*] of Y27_C_SALES_ITEM as _soItem
{
    key sales_doc_num,
    date_created,
    person_created,
    sales_org,
    sales_dist,
    sales_div,
    total_cost,
    cost_currency,
    case block_status
        when '98' then 2
        when 'X' then 1
        else 3
    end as block_status, 
    case block_status
        when '98' then 'yet to Approve'
        when 'X' then 'Blocked'
        else 'Approved'
    end as block_status_msg, 
    last_changed,
    /* Associations */
    _soItem
}
