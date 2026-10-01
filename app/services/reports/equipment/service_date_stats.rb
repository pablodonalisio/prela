class Reports::Equipment::ServiceDateStats < Reports::Content
  def render
    @pdf.move_down 10
    service_date_stats
    super
  end

  private

  def service_date_stats
    if assigned_services.any?
      create_table_with_service_dates
      foot_notes
    else
      @pdf.text "Sin servicios", size: 10
    end
  end

  def create_table_with_service_dates
    table_width = @pdf.bounds.width
    @pdf.table([
      dates_header,
      *equipment_rows
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 6
    end
  end

  def equipment_rows
    assigned_services.map { |les| maintenance_row(les) }
  end

  def assigned_services
    @assigned_services ||= location_equipment.location_equipment_services.includes(:service_kind).order("service_kinds.name")
  end

  def dates_header
    [{content: "Mantenimiento preventivo", colspan: 6, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}]
  end

  def maintenance_row(les)
    last_label = "Último #{les.service_kind.name}"
    next_label = les.recurring? ? "Próximo #{les.service_kind.name}" : "Vencimiento #{les.service_kind.name}"
    next_date = les.next_due_on

    [
      {content: last_label, background_color: PRIMARY_COLOR},
      {content: formated_date(les.last_completed_on)},
      {content: next_label, background_color: PRIMARY_COLOR},
      {content: formated_date(next_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR},
      {content: date_past?(next_date)}
    ]
  end

  def date_past?(date)
    return unless date

    (date && date < Date.today) ? "Sí" : "No"
  end

  def formated_date(date)
    I18n.l(date, format: "%B %Y") if date
  end

  def foot_notes
    if equipment.ups?
      @pdf.move_down 10
      @pdf.text "*Los cambios de baterías de las UPS dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
    elsif equipment.power_unit?
      @pdf.move_down 10
      @pdf.text "*Los cambios de baterías y correas de los grupos electrógenos dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
    end
  end
end
