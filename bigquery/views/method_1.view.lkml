
###  Period over Period Method 1: Use Looker's native date dimension groups

view: order_items {
  sql_table_name: looker-test-db.looker_test_tokyo.order_items ;;


  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    # Not originally in the article
    view_label: "_PoP"
    type: number
    sql: ${TABLE}.orders_id ;;
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
    #add 1450 days as a test for shifting the old timestamp to recent timestamp
    sql: timestamp_add(${TABLE}.created_at, interval 1450 day) ;;
    convert_tz: no
  }


#(Method 1a) you may also wish to create MTD and YTD filters in LookML

  dimension: wtd_only {
    group_label: "To-Date Filters"
    label: "WTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAYOFWEEK FROM ${created_raw}) < EXTRACT(DAYOFWEEK FROM CURRENT_DATE())
                OR
            (EXTRACT(DAYOFWEEK FROM ${created_raw}) = EXTRACT(DAYOFWEEK FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM CURRENT_TIME()))
                OR
            (EXTRACT(DAYOFWEEK FROM ${created_raw}) = EXTRACT(DAYOFWEEK FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM CURRENT_TIME()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM CURRENT_TIME())))  ;;
  }

  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAY FROM ${created_raw}) < EXTRACT(DAY FROM CURRENT_DATE())
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM CURRENT_TIME()))
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM CURRENT_TIME()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM CURRENT_TIME())))  ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAYOFYEAR FROM ${created_raw}) < EXTRACT(DAYOFYEAR FROM CURRENT_DATE())
                OR
            (EXTRACT(DAYOFYEAR FROM ${created_raw}) = EXTRACT(DAYOFYEAR FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM CURRENT_TIME()))
                OR
            (EXTRACT(DAYOFYEAR FROM ${created_raw}) = EXTRACT(DAYOFYEAR FROM CURRENT_DATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM CURRENT_TIME()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM CURRENT_TIME())))  ;;
  }

  dimension: sale_price {
    # not originally in the article
    view_label: "_PoP"
    sql: ${TABLE}.sale_price ;;
  }

  measure: count {
    label: "Count of order_items"
    type: count
    hidden: yes
  }
  measure: count_orders {
    label: "Count of orders"
    type: count_distinct
    sql: ${order_id} ;; #there was no dimension called `order_id`
    hidden: yes
  }

  measure: total_sale_price {
    label: "Total Sales"
    view_label: "_PoP"
    type: sum
    sql: ${sale_price} ;; #there's no dimension called `sale_price`
    value_format_name: usd
    drill_fields: [created_date]
  }
}
