###  Period over Period Method 8: Compare any period to any other period
# the most complex implementation, but also the most flexible


#### ------------ VIEWS TO LEAVE ALONE  ------------ ###

# This view sets up the config (doesn't need editing)
view: pop {
  sql_table_name: (SELECT NULL) ;;
  view_label: "_PoP"

### ------------ (HIDDEN) FILTERS TO CUSTOMIZE THE APPROACH ------------


# Choose a date range to filter on
  filter: date_filter  {
    label: "1. Date Range"
    hidden: yes
    type: date
    convert_tz: no
  }

# A second filter to choose number of past periods. Defaults to 1 if this is not selected
  filter: over_how_many_past_periods {
    label: "Override past periods"
    description: "Apply this filter to add past periods to compare to (from the default of current vs 1 period ago)"
    type: number
    default_value: "<=1"
  }


# # Choose how to break the range down - normally done with a parameter but here is a dimension
#   dimension: within_period_type {
#     label: "2. Break down date range by"
#     hidden: yes
#     type: string
# #Using case just to get friendlier UI experience in filters. Otherwise, could have a no-sql filter field
#     case: {
#       when: {
#         sql: {% parameter pop.within_period_type %}='quarter' ;;
#         label: "quarter"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='month' ;;
#         label: "month"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='week' ;;
#         label: "week"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='day' ;;
#         label: "day"
#       }
#       when: {
#         sql: {% parameter pop.within_period_type %}='hour' ;;
#         label: "hour"
#       }
#     }
#   }

parameter: within_period_type {
  label: "2. Break down date range by"
    # hidden: yes
    type: unquoted
    allowed_value: {
      label: "quarter"
      value: "quarter"
    }
    allowed_value: {
      label: "month"
      value: "month"
    }
    allowed_value: {
      label: "week"
      value: "week"
    }
    allowed_value: {
      label: "day"
      value: "day"
    }
    allowed_value: {
      label: "hour"
      value: "hour"
    }
}

# Choose the previous period
# # Again we use a dimension here instead of a parameter
#   dimension: over_period_type {
#     label: "3. Compare over"
#     hidden: yes
#     type: string
# #Using case just to get friendlier UI experience in filters. Otherwise, could have a no-sql filter field
#     case: {
#       when: {
#         sql: {% parameter pop.over_period_type %}='year' ;;
#         label: "year"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='quarter' ;;
#         label: "quarter"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='month' ;;
#         label: "month"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='week' ;;
#         label: "week"
#       }
#       when: {
#         sql: {% parameter pop.over_period_type %}='day' ;;
#         label: "day"
#       }
#     }
#   }


parameter: over_period_type {
  label: "3. Compare over"
  hidden: yes
  type: unquoted
  allowed_value: {
    label: "year"
    value: "year"
  }
  allowed_value: {
    label: "quarter"
    value: "qurater"
  }
  allowed_value: {
    label: "month"
    value: "month"
  }
  allowed_value: {
    label: "week"
    value: "week"
  }
  allowed_value: {
    label: "day"
    value: "day"
  }
}

### ------------ DIMENSIONS WE WILL ACTUALLY PLOT ------------


# This is the dimension we will plot as rows
# This version is always ordered correctly
  dimension: reference_date {
    hidden: yes
#type: date_time <-- too aggressive with choosing your string formatting for you
#type: date <-- too aggressive with truncating the time part
#convert_tz: no
#type: nothing <-- just right
    sql: DATE_TRUNC(
    DATE_ADD(DATE({% date_end pop.date_filter %}), INTERVAL 0 - ${within_periods.n} {% parameter pop.within_period_type %})
    , {% parameter pop.within_period_type %});;
  }

# This is the version we will actually plot in the data with nice formatting
  dimension: reference_date_formatted {
    type: string
    order_by_field: reference_date
    label: "Reference date"
    sql:
    --TO_CHAR(
    CAST(${reference_date} AS STRING FORMAT
          (CASE '{% parameter pop.within_period_type %}'
           WHEN 'year' THEN 'YYYY'
            WHEN 'month' THEN 'MON YY'
            WHEN 'quarter' THEN 'YYYY"Q"Q'
            WHEN 'week' THEN 'MM/DD/YY' --or 'YYYY"W"WW' or 'YY-MM"W"W'
            WHEN 'day' THEN 'MM/DD/YY'
            WHEN 'hour' THEN 'MM/DD HHam'
          ELSE 'MM/DD/YY'
          END)
          )
          ;;}


      # This is the dimension we will plot as pivots
      dimension: over_periods_ago  {
        label: "Prior Periods"
        description: "Pivot me!"
        sql: CASE ${over_periods.n}
                WHEN 0 THEN 'Current '||'{% parameter pop.over_period_type %}'
                WHEN 1 THEN ${over_periods.n}||' '||'{% parameter pop.over_period_type %}' || ' prior'
                ELSE        ${over_periods.n}||' '||'{% parameter pop.over_period_type %}' || 's prior'
                END;;
        order_by_field: over_periods.n
      }
    }

# This view establishes the max number of previous periods (doesn't need editing)
    view: numbers {
      sql_table_name: (
            SELECT 00 as n UNION ALL SELECT 01 UNION ALL SELECT 02 UNION ALL
            SELECT 03 UNION ALL SELECT 04 UNION ALL SELECT 05 UNION ALL
            SELECT 06 UNION ALL SELECT 07 UNION ALL SELECT 08 UNION ALL
            SELECT 09 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
            SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL
            SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL
            SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL
            SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL
            SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL
            SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL
            SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL
            SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL
            SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL
            SELECT 39 UNION ALL SELECT 40 UNION ALL SELECT 41 UNION ALL
            SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL
            SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL
            SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50 UNION ALL
            SELECT 51 UNION ALL SELECT 52 )
        ;;
      dimension: n {
        type: number
        # hidden:  yes
        sql: ${TABLE}.n ;;
      }
    }

#### ------------ VIEWS TO EDIT  ------------ ###

    view: pop_order_items_created {
      view_label: "Order Items (By created date)"
      sql_table_name: (
        SELECT
            DATE_TRUNC(order_items.created_at, {% parameter pop.within_period_type %}) as join_date,
            COUNT(*) as agg_1,
            SUM(order_items.sale_price) as agg_2
            -- FROM order_items
           FROM looker-test-db.looker_test_tokyo.order_items
            GROUP BY 1
            ) ;;

        measure:  agg_1 {
          type:  number
          label: "Count"
          sql: SUM(${TABLE}.agg_1) ;;
        }
        measure:  agg_2 {
          type:  number
          label: "Total Sales"
          sql: SUM(${TABLE}.agg_2) ;;
        }
      }



#### ------------ EXTENSIBLE VERSION (Multiple dates)  ------------ ###
## This is what the above looks like if we scale it to work with multiple date fields
## We make one view per date and join them all to the model

      view: pop_order_items_delivered {
        view_label: "Order Items (By delivered)"
        sql_table_name: (SELECT
              DATE_TRUNC(order_items.shipped_at, {% parameter pop.within_period_type %}) as join_date,
              COUNT(*) as agg_1,
              SUM(order_items.sale_price) as agg_2
              FROM order_items
              WHERE {%condition pop_order_items_delivered.sale_price %}order_items.sale_price{% endcondition %}
              GROUP BY 1
              ) ;;
      }
