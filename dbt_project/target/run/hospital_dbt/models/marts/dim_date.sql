
  
    

  create  table "neondb"."public_marts"."dim_date__dbt_tmp"
  
  
    as
  
  (
    -- models/marts/dim_date.sql
-- Date dimension covering all appointment dates (2023).

with date_spine as (
    select generate_series(
        '2023-01-01'::date,
        '2024-12-31'::date,
        '1 day'::interval
    )::date as full_date
)

select
    to_char(full_date, 'YYYYMMDD')::int         as date_key,
    full_date,
    extract(year    from full_date)::int         as year,
    extract(quarter from full_date)::int         as quarter,
    extract(month   from full_date)::int         as month,
    to_char(full_date, 'Month')                  as month_name,
    extract(week    from full_date)::int         as week_of_year,
    extract(day     from full_date)::int         as day_of_month,
    extract(dow     from full_date)::int         as day_of_week,
    to_char(full_date, 'Day')                    as day_name,
    (extract(dow from full_date) in (0, 6))      as is_weekend
from date_spine
  );
  