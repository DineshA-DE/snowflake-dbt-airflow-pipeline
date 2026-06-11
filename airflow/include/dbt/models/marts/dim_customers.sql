with customers as (
    select * from {{ ref('stg_customers') }}
),

nations as (
    select * from {{ ref('stg_nations') }}
),

final as (
    select
        customers.customer_id,
        customers.customer_name,
        nations.nation_name,
        nations.region_id,
        customers.market_segment,

        -- using macro to convert account balance from cents to dollars
        {{ cents_to_dollars('customers.account_balance') }} as account_balance_usd,

        customers.phone,
        customers.address

    from customers
    inner join nations
        on customers.nation_id = nations.nation_id
)

select * from final