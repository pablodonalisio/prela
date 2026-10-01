module LocationEquipmentsHelper
  CONDITION_BADGE_CLASSES = {
    "success" => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
    "warning" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
    "danger" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300"
  }.freeze

  OCCURRENCE_STATUS_BADGE_CLASSES = {
    completed: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
    scheduled: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
    suspended: "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300",
    cancelled: "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300",
    pending: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300"
  }.freeze

  def humanize_floor(floor)
    return unless floor

    if floor < -1
      "Subsuelo #{floor.abs}"
    elsif floor.eql?(-1)
      "Subsuelo"
    elsif floor.eql?(0)
      "PB"
    else
      floor
    end
  end

  def service_date_color(date)
    return unless date

    if date < Time.current
      "text-red-500"
    elsif date < Date.today.months_since(3)
      "text-yellow-500"
    else
      "text-green-500"
    end
  end

  def condition_badge_classes(color)
    CONDITION_BADGE_CLASSES.fetch(color.to_s, "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300")
  end

  def occurrence_status_badge_classes(occurrence)
    key = %i[completed scheduled suspended cancelled].find { |status| occurrence.public_send("#{status}?") } || :pending
    OCCURRENCE_STATUS_BADGE_CLASSES.fetch(key)
  end

  def failures_last_year_indicator(location_equipment)
    "Último año: #{location_equipment.failures_last_year_count}"
  end

  def average_failures_indicator(location_equipment)
    average = location_equipment.average_failures_per_active_year
    return "—" if average.nil?

    years = location_equipment.active_years_since_metrics_start
    tooltip = "El tiempo de actividad se considera en base al tiempo que el Activo se encuentra en estado 'En Servicio'"

    safe_join([
      "Promedio: #{number_with_precision(average, precision: 1)} / año en ",
      tag.span(
        "#{number_with_precision(years, precision: 1)} años de actividad",
        data: {
          controller: "tooltip",
          tooltip_text_value: tooltip
        },
        class: "cursor-help underline decoration-dotted"
      )
    ])
  end
end
