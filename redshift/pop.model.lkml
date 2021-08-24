connection: "thelook_events"

include: "*.view.lkml"                # include all views in the views/ folder in this project

explore: order_items {
  label: "PoP Method 1: Use Looker's native date dimension groups"
}

explore: pop_simple {
  label: "PoP Method 2: Allow users to choose periods with parameters"
  always_filter: {
    filters: [pop_simple.choose_comparison: "", pop_simple.choose_breakdown: ""]
}
}

explore: pop_parameters {
  label: "PoP Method 3: Custom choice of current and previous periods with parameters"
  always_filter: {
    filters: [current_date_range: "6 months", compare_to: "Year" ]
  }
}

explore: pop_parameters_multi_period {
  label: "PoP Method 4: Compare multiple templated periods"
  extends: [pop_parameters]
  sql_always_where:
        {% if pop_parameters_multi_period.current_date_range._is_filtered %} {% condition pop_parameters_multi_period.current_date_range %} ${created_raw} {% endcondition %}
        {% if pop_parameters_multi_period.previous_date_range._is_filtered or pop_parameters_multi_period.compare_to._in_query %}
        {% if pop_parameters_multi_period.comparison_periods._parameter_value == "2" %}
            or ${created_raw} between ${period_2_start} and ${period_2_end}
        {% elsif pop_parameters_multi_period.comparison_periods._parameter_value == "3" %}
            or ${created_raw} between ${period_2_start} and ${period_2_end}
            or ${created_raw} between ${period_3_start} and ${period_3_end}
        {% elsif pop_parameters_multi_period.comparison_periods._parameter_value == "4" %}
            or ${created_raw} between ${period_2_start} and ${period_2_end}
            or ${created_raw} between ${period_3_start} and ${period_3_end} or ${created_raw} between ${period_4_start} and ${period_4_end}
        {% else %} 1 = 1
        {% endif %}
        {% endif %}
        {% else %} 1 = 1
        {% endif %};;
}


explore: pop_parameters_with_custom_range {
  label: "PoP Method 5: Compare current period with another arbitrary period"
  always_filter: {
    filters: [current_date_range: "1 month", previous_date_range: "2 months ago for 2 days"]
  }
}

explore: pop_arbitrary {
  label: "PoP Method 6: Compare two arbitrary date ranges"
  always_filter: {
    filters: [period_selected:"-NULL",pop_arbitrary.first_period_filter: "", pop_arbitrary.second_period_filter: ""]
  }
}

explore: pop_previous {
  label: "PoP Method 7: Compare any period with the previous period"
  always_filter: {
    filters: [pop_previous.date_filter: ""]
  }
  sql_always_where: ${timeframes} <>'Not in time period' ;;
}

explore: flexible_pop {
  label: "PoP Method 8: Flexible implementation to compare any period to any other"
  from:  pop
  view_name: pop

  # No editing needed - make sure we always join and set up always filter on the hidden config dimensions
  always_join: [within_periods,over_periods]
  always_filter: {
    filters: [pop.date_filter: "last 12 weeks", pop.within_period_type: "week", pop.over_period_type: "year"]
  }

# No editing needed
  join: within_periods {
    from: numbers
    type: left_outer
    relationship: one_to_many
    fields: []
    # This join creates fanout, creating one additional row per required period
    # Here we calculate the size of the current period, in the units selected by the filter
    # The DATEDIFF unit is in days, so if we want hours we have to multiply it by 24
    # (It might be possible to make this more efficient with a more granular function like TIMESTAMPDIFF where you can specify the interval units)
    sql_on: ${within_periods.n}
            <= DATEDIFF( {% parameter pop.within_period_type %},{% date_start pop.date_filter %},{% date_end pop.date_filter %} )
             * CASE WHEN {%parameter pop.within_period_type %} = 'hour' THEN 24 ELSE 1 END;;
  }
# No editing needed
  join: over_periods {
    from: numbers
    view_label: "_PoP"
    type: left_outer
    relationship: one_to_many
    sql_on:
                  CASE WHEN {% condition pop.over_how_many_past_periods %} NULL {% endcondition %}
                  THEN
                    ${over_periods.n} <= 1
                  ELSE
                    {% condition pop.over_how_many_past_periods %} ${over_periods.n} {% endcondition %}
                  END;;
  }

# Rename (& optionally repeat) below join to match your pop view(s)
  join: pop_order_items_created {
    type: left_outer
    relationship: many_to_one
    #Apply join name below in sql_on
    sql_on: pop_order_items_created.join_date = DATE_TRUNC({% parameter pop.within_period_type %},
                      DATEADD({% parameter pop.over_period_type %}, 0 - ${over_periods.n},
                          DATEADD({% parameter pop.within_period_type %}, 0 - ${within_periods.n},
                              {% date_end pop.date_filter %}
                          )
                      )
                  );;
  }

}
