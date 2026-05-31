with orders as (
    -- get all cleaned orders from staging
    select * from {{ ref('stg_orders') }}
),

lineitems as (
    -- get all cleaned line items from staging
    select * from {{ ref('stg_lineitems') }}
),

joined as (
    select
        -- order details
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status_code,
        orders.priority,

        -- line item details
        lineitems.part_id,
        lineitems.supplier_id,
        lineitems.line_number,
        lineitems.quantity,
        lineitems.extended_price,
        lineitems.discount,
        lineitems.tax,
        lineitems.ship_date,
        lineitems.ship_mode,
        lineitems.return_flag,
        -- extented price is the original price
        -- calculate actual revenue after discount and tax
        -- formula: price × (1 - discount) × (1 + tax)
        -- example: $100 × (1 - 0.05) × (1 + 0.08) = $102.60
        round(
            lineitems.extended_price * (1 - lineitems.discount) * (1 + lineitems.tax),
            2
        ) as gross_revenue

    from orders
    inner join lineitems
        on orders.order_id = lineitems.order_id
)

select * from joined