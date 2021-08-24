
###  Period over Period Method 5:
###Compare current period with another arbitrary period

## Like Method 3, but allows you to compare the current period with
## any other arbitrary date range period



include: "method3.view.lkml"

## This extended version allows the user to also choose a custom date range for the previous period

view: pop_parameters_with_custom_range {
  extends: [pop_parameters]


## This extended version allows the user to also choose a custom date
##range for the previous period



    # custom date range
    filter: previous_date_range {
      type: date
      view_label: "_PoP"
      label: "2a. Previous Date Range (Custom):"
      description: "Select a custom previous period you would like to compare to. Must be used with Current Date Range filter."
    }

    parameter: compare_to {label: "2b. Compare To:"}
    dimension_group: date_in_period {hidden:yes}

    dimension: period_2_start {
      view_label: "_PoP"
      description: "Calculates the start of the previous period"
      type: date
      sql:
        {% if compare_to._in_query %}
            {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -${days_in_period}, DATE({% date_start current_date_range %}))
            {% else %}
            DATEADD({% parameter compare_to %}, -1, DATE({% date_start current_date_range %}))
            {% endif %}
        {% else %}
            {% date_start previous_date_range %}
        {% endif %};;
      hidden:  yes
    }

    dimension: period_2_end {
      hidden:  yes
      view_label: "_PoP"
      description: "Calculates the end of the previous period"
      type: date
      sql:
        {% if compare_to._in_query %}
            {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -1, DATE({% date_start current_date_range %}))
            {% else %}
            DATEADD({% parameter compare_to %}, -1, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
            {% endif %}
        {% else %}
            {% date_end previous_date_range %}
        {% endif %};;
    }
 }
