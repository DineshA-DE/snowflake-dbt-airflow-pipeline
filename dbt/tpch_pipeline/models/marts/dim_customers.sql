with customers as (
    -- get clean customer data from staging
    select * from {{ ref('stg_customers') }}
),

nations as (
    -- get nation names from staging
    select * from {{ ref('stg_nations') }}
),

final as (
    select
        -- customer identifiers
        customers.customer_id,
        customers.customer_name,

        -- replace nation_id number with actual nation name
        nations.nation_name,
        nations.region_id,

        -- customer descriptive details
        customers.market_segment,
        customers.account_balance,
        customers.phone,
        customers.address

    from customers
    inner join nations
        on customers.nation_id = nations.nation_id
)

select * from final