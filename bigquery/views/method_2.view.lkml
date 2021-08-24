###  Period over Period Method 2: Allow users to choose periods with parameters

  include: "/views/method_1.view.lkml"
  view: pop_simple {
    extends: [order_items]

    parameter: choose_breakdown {
      label: "Choose Grouping (Rows)"
      view_label: "_PoP"
      type: unquoted
      default_value: "Month"
      allowed_value: {label: "Month Name" value:"Month"}
      allowed_value: {label: "Day of Year" value: "DOY"}
      allowed_value: {label: "Day of Month" value: "DOM"}
      allowed_value: {label: "Day of Week" value: "DOW"}
      allowed_value: {value: "Date"}
    }

    parameter: choose_comparison {
      label: "Choose Comparison (Pivot)"
      view_label: "_PoP"
      type: unquoted
      default_value: "Year"
      allowed_value: {value: "Year" }
      allowed_value: {value: "Month"}
      allowed_value: {value: "Week"}
    }

    dimension: pop_row  {
      view_label: "_PoP"
      label_from_parameter: choose_breakdown
      type: string
      # order_by_field: sort_hack1 # Important # WON: no dimension called sort_hack1
      order_by_field: sort_by1
      sql:
          {% if choose_breakdown._parameter_value == 'Month' %} ${created_month_name}
          {% elsif choose_breakdown._parameter_value == 'DOY' %} ${created_day_of_year}
          {% elsif choose_breakdown._parameter_value == 'DOM' %} ${created_day_of_month}
          {% elsif choose_breakdown._parameter_value == 'DOW' %} ${created_day_of_week}
          {% elsif choose_breakdown._parameter_value == 'Date' %} ${created_date}
          {% else %}NULL{% endif %} ;;
    }

    dimension: pop_pivot {
      view_label: "_PoP"
      label_from_parameter: choose_comparison
      type: string
      # order_by_field: sort_hack2 # Important # WON: no dimension called sort_hack2
      order_by_field: sort_by2
      sql:
          {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
          {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month_name}
          {% elsif choose_comparison._parameter_value == 'Week' %} ${created_week}
          {% else %}NULL{% endif %} ;;
    }


    # These dimensions are just to make sure the dimensions sort correctly
    dimension: sort_by1 {
      hidden: yes
      type: number
      sql:
          {% if choose_breakdown._parameter_value == 'Month' %} ${created_month_num}
          {% elsif choose_breakdown._parameter_value == 'DOY' %} ${created_day_of_year}
          {% elsif choose_breakdown._parameter_value == 'DOM' %} ${created_day_of_month}
          {% elsif choose_breakdown._parameter_value == 'DOW' %} ${created_day_of_week_index}
          {% elsif choose_breakdown._parameter_value == 'Date' %} ${created_date}
          {% else %}NULL{% endif %} ;;
    }

    dimension: sort_by2 {
      hidden: yes
      type: string
      sql:
          {% if choose_comparison._parameter_value == 'Year' %} ${created_year}
          {% elsif choose_comparison._parameter_value == 'Month' %} ${created_month_num}
          {% elsif choose_comparison._parameter_value == 'Week' %} ${created_week}
          {% else %}NULL{% endif %} ;;
    }
  }
