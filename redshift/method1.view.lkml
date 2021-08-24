### https://help.looker.com/hc/en-us/articles/360050104194-Methods-for-Period-Over-Period-PoP-Analysis-in-Looker
### Period over Period Method 1: Use Looker's native date dimension groups

view: order_items {
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    view_label: "_PoP"
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      day_of_week,
      day_of_week_index,
      day_of_month,
      day_of_year,
      week,
      week_of_year,
      month,
      month_name,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
    convert_tz: no
  }


#(Method 1a) you may also wish to create MTD and YTD filters in LookML

  dimension: wtd_only {
    group_label: "To-Date Filters"
    label: "WTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOW FROM ${created_raw}) < EXTRACT(DOW FROM GETDATE())
              OR
          (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
              OR
          (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
          EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAY FROM ${created_raw}) < EXTRACT(DAY FROM GETDATE())
              OR
          (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
              OR
          (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
          EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOY FROM ${created_raw}) < EXTRACT(DOY FROM GETDATE())
              OR
          (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
              OR
          (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
          EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  measure: count {
    label: "Count of order_items"
    type: count
    hidden: yes
  }
  measure: count_orders {
    label: "Count of orders"
    type: count_distinct
    sql: ${TABLE}.order_id ;;
    hidden: yes
  }

  measure: total_sale_price {
    label: "Total Sales"
    view_label: "_PoP"
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    drill_fields: [created_date]
  }

}
