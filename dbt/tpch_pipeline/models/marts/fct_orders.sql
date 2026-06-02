{{
    config(
        materialized='incremental',
        unique_key='order_key'
    )
}}

with order_items as (
    select * from {{ ref('int_order_items') }}

    -- this block only runs when the model already exists
    -- it filters to only NEW records since the last run
    {% if is_incremental() %}
        where order_date > (select max(order_date) from {{ this }})
    {% endif %}
),

final as (
    select
        -- surrogate key using dbt_utils
        {{ dbt_utils.generate_surrogate_key(['order_id', 'ship_mode']) }} as order_key,

        -- order identifiers
        order_id,
        customer_id,
        order_date,
        status_code,
        priority,
        ship_mode,

        -- order metrics
        round(sum(gross_revenue), 2)    as total_revenue,
        count(line_number)              as total_line_items,
        sum(quantity)                   as total_quantity,
        round(avg(discount), 4)         as avg_discount,
        min(ship_date)                  as first_ship_date,
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