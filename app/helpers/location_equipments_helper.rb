module LocationEquipmentsHelper
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
      "text-danger"
    elsif date < Date.today.months_since(3)
      "text-warning"
    else
      "text-success"
    end
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
          bs_toggle: "tooltip",
          bs_title: tooltip
        },
        class: "text-decoration-underline",
        style: "text-decoration-style: dotted; cursor: help;"
      )
    ])
  end
end
