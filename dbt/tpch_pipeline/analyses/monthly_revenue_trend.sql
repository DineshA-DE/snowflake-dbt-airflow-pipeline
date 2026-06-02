with monthly_revenue as (
    select
        date_trunc('month', order_date)     as order_month,
        sum(total_revenue)                  as monthly_revenue,
        count(distinct order_id)            as total_orders,
        round(avg(total_revenue), 2)        as avg_order_revenue
    from {{ ref('fct_orders') }}
    group by 1
)
select
    order_month,
    monthly_revenue,
    total_orders,
    avg_order_revenue,
    round(
        (monthly_revenue - lag(monthly_revenue) over (order by order_month))
        / lag(monthly_revenue) over (order by order_month) * 100,
        2
    ) as revenue_growth_pct
from monthly_revenue
order by order_month