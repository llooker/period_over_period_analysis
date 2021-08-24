


###  Period over Period Method 4: Compare multiple templated periods

# Like Method 3, but expanded to compare more than two periods
### Needed to add convert_tz: no to all type date dimensions to avoid double-timezone conversion##


include: "method3.view.lkml"
# This extended version allows you to choose multiple periods (this can also work in conjunction with the custom range version, or separately)

view: pop_parameters_multi_period {
  extends: [pop_parameters]

    parameter: comparison_periods {
      view_label: "_PoP"
      label: "3. Number of Periods"
      description: "Choose the number of periods you would like to compare."
      type: unquoted
      allowed_value: {
        label: "2"
        value: "2"
      }
      allowed_value: {
        label: "3"
        value: "3"
      }
      allowed_value: {
        label: "4"
        value: "4"
      }
      default_value: "2"
    }

    dimension: period_3_start {
      view_label: "_PoP"
      description: "Calculates the start of 2 periods ago"
      type: date
      sql:
          {% if compare_to._parameter_value == "Period" %}
              DATEADD(DAY, -(2 * ${days_in_period}), DATE({% date_start current_date_range %}))
          {% else %}
              DATEADD({% parameter compare_to %}, -2, DATE({% date_start current_date_range %}))
          {% endif %};;
       hidden: yes
      convert_tz: no

    }

    dimension: period_3_end {
      view_label: "_PoP"
      description: "Calculates the end of 2 periods ago"
      type: date
      sql:
          {% if compare_to._parameter_value == "Period" %}
              DATEADD(DAY, -1, ${period_2_start})
          {% else %}
              DATEADD({% parameter compare_to %}, -2, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
          {% endif %};;
       hidden: yes
      convert_tz: no
    }

    dimension: period_4_start {
      view_label: "_PoP"
      description: "Calculates the start of 4 periods ago"
      type: date
      sql:
          {% if compare_to._parameter_value == "Period" %}
              DATEADD(DAY, -(3 * ${days_in_period}), DATE({% date_start current_date_range %}))
          {% else %}
              DATEADD({% parameter compare_to %}, -3, DATE({% date_start current_date_range %}))
          {% endif %};;
       hidden: yes
      convert_tz: no
    }

    dimension: period_4_end {
      view_label: "_PoP"
      description: "Calculates the end of 4 periods ago"
      type: date
      sql:
        {% if compare_to._parameter_value == "Period" %}
        DATEADD(DAY, -1, ${period_2_start})
        {% else %}
        DATEADD({% parameter compare_to %}, -3, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
        {% endif %};;
       hidden: yes
      convert_tz: no
    }

    dimension: period {
      view_label: "_PoP"
      label: "Period "
      description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period', 'Previous Period' or '3 Periods Ago'"
      type: string
      order_by_field: order_for_period
      sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
            THEN 'This {% parameter compare_to %}'
            WHEN ${created_date} between ${period_2_start} and ${period_2_end}
            THEN 'Last {% parameter compare_to %}'
            WHEN ${created_date} between ${period_3_start} and ${period_3_end}
            THEN '2 {% parameter compare_to %}s Ago'
            WHEN ${created_date} between ${period_4_start} and ${period_4_end}
            THEN '3 {% parameter compare_to %}s Ago'
            END
        {% else %}
            NULL
        {% endif %}
        ;;
    }

    dimension: order_for_period {
      hidden: yes
      view_label: "Comparison Fields"
      label: "Period"
      type: string
      sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
            THEN 1
            WHEN ${created_date} between ${period_2_start} and ${period_2_end}
            THEN 2
            WHEN ${created_date} between ${period_3_start} and ${period_3_end}
            THEN 3
            WHEN ${created_date} between ${period_4_start} and ${period_4_end}
            THEN 4
            END
        {% else %}
            NULL
        {% endif %}
        ;;
    }
    dimension: day_in_period {
      view_label: "_PoP"
      description: "Gives the number of days since the start of each periods. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
      type: number
      sql:
          {% if current_date_range._is_filtered %}
              CASE
              WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
              THEN DATEDIFF(DAY, DATE({% date_start current_date_range %}), ${created_date}) + 1

              WHEN ${created_date} between ${period_2_start} and ${period_2_end}
              THEN DATEDIFF(DAY, ${period_2_start}, ${created_date}) + 1

              WHEN ${created_date} between ${period_3_start} and ${period_3_end}
              THEN DATEDIFF(DAY, ${period_3_start}, ${created_date}) + 1

              WHEN ${created_date} between ${period_4_start} and ${period_4_end}
              THEN DATEDIFF(DAY, ${period_4_start}, ${created_date}) + 1
              END

          {% else %} NULL
          {% endif %}
          ;;
       hidden: yes
    }
  }
