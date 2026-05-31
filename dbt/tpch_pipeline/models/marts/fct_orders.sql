with order_items as (
    -- pull all order items from intermediate layer
    select * from {{ ref('int_order_items') }}
),

final as (
    select
        -- order identifiers
        order_id,
        customer_id,
        order_date,
        status_code,
        priority,
        ship_mode,

        -- order metrics (one row per order)
        -- sum all line item revenues to get total order revenue
        round(sum(gross_revenue), 2)    as total_revenue,

        -- count how many items were in this order
        count(line_number)              as total_line_items,

        -- sum total quantity of all items ordered
        sum(quantity)                   as total_quantity,

        -- average discount applied across all items in this order
        round(avg(discount), 4)         as avg_discount,

        -- earliest ship date among all items in this order
        min(ship_date)                  as first_ship_date,

        -- latest ship date among all items in this order
        max(ship_date)                  as last_ship_date

    from order_items
    group by
        order_id,
        customer_id,
        order_date,
        status_code,
        priority,
        ship_mode
)

select * from final