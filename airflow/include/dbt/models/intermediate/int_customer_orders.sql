with customers as (
    -- get all cleaned customers from staging
    select * from {{ ref('stg_customers') }}
),

nations as (
    -- get all nation names from staging
    select * from {{ ref('stg_nations') }}
),

order_items as (
    -- get all order items we just built in the previous model
    select * from {{ ref('int_order_items') }}
),

customers_with_nations as (
    -- join customers with nations to replace nation_id with actual nation name
    select
        customers.customer_id,
        customers.customer_name,
        customers.address,
        customers.phone,
        customers.account_balance,
        customers.market_segment,
        nations.nation_name,
        nations.region_id
    from customers
    inner join nations
        on customers.nation_id = nations.nation_id
),

final as (
    -- join customers (with nation names) to their orders
    -- and calculate total revenue per customer per order
    select
        customers_with_nations.customer_id,
        customers_with_nations.customer_name,
        customers_with_nations.nation_name,
        customers_with_nations.market_segment,
        customers_with_nations.account_balance,
        order_items.order_id,
        order_items.order_date,
        order_items.status_code,
        order_items.priority,
        order_items.ship_mode,

        -- total revenue for this order
        sum(order_items.gross_revenue) as order_revenue,

        -- total items in this order
        count(order_items.line_number) as total_line_items

    from customers_with_nations
    inner join order_items
        on customers_with_nations.customer_id = order_items.customer_id

    group by
        customers_with_nations.customer_id,
        customers_with_nations.customer_name,
        customers_with_nations.nation_name,
        customers_with_nations.market_segment,
        customers_with_nations.account_balance,
        order_items.order_id,
        order_items.order_date,
        order_items.status_code,
        order_items.priority,
        order_items.ship_mode
)

select * from final