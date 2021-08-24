
view: order_items {
  sql_table_name: (select order_items1.*, orders1.created_at from demo_db.order_items as order_items1 join demo_db.orders as orders1 on order_items1.order_id = orders1.id) ;;

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
    sql: date_add(${TABLE}.created_at, INTERVAL 2 YEAR) ;;
    convert_tz: no
  }


#(Method 1a) you may also wish to create MTD and YTD filters in LookML

  dimension: wtd_only {
    group_label: "To-Date Filters"
    label: "WTD"
    view_label: "_PoP"
    type: yesno
    sql:  (DAYOFWEEK(${created_raw}) < DAYOFWEEK(CURDATE())
              OR
          (DAYOFWEEK(${created_raw}) = DAYOFWEEK(CURDATE()) AND
          HOUR(${created_raw}) < HOUR (CURTIME()))
              OR
          (DAYOFWEEK(${created_raw}) = DAYOFWEEK(CURDATE()) AND
          HOUR (${created_raw}) <= HOUR (CURTIME()) AND
          MINUTE (${created_raw}) < MINUTE (CURTIME())));;
  }

  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  (MONTH( ${created_raw}) < MONTH(CURDATE())
              OR
          (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM CURDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM CURDATE()))
              OR
          (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM CURDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM CURTIME()) AND
          EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM CURTIME())))  ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  (DAYOFYEAR(${created_raw}) < DAYOFYEAR( CURDATE())
              OR
          (DAYOFYEAR (${created_raw}) = DAYOFYEAR( CURDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM CURTIME()))
              OR
          (DAYOFYEAR(${created_raw}) = DAYOFYEAR(CURDATE()) AND
          EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM CURTIME()) AND
          EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM CURTIME())))  ;;
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
