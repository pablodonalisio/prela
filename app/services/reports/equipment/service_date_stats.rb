class Reports::Equipment::ServiceDateStats < Reports::Content
  def render
    @pdf.move_down 10
    service_date_stats
    super
  end

  private

  def service_date_stats
    if equipment.ups?
      create_table_with(ups_rows)
      ups_foot_notes
    elsif equipment.power_unit?
      create_table_with(power_unit_rows)
      power_unit_foot_notes
    end
  end

  def create_table_with(equipment_rows)
    table_width = @pdf.bounds.width
    @pdf.table([
      dates_header,
      *equipment_rows
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 6
    end
  end

  def ups_rows
    [service_dates_row, battery_dates_row]
  end

  def power_unit_rows
    [service_dates_row, battery_dates_row, belt_dates_row]
  end

  def dates_header
    [{content: "Mantenimiento preventivo", colspan: 6, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}]
  end

  def service_dates_row
    [{content: "Último Servicio", background_color: PRIMARY_COLOR}, {content: formated_date(last_service_date)},
      {content: "Próximo Servicio", background_color: PRIMARY_COLOR}, {content: formated_date(next_service_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_service_date)}]
  end

  def battery_dates_row
    [{content: "Último Cambio de Batería", background_color: PRIMARY_COLOR}, {content: formated_date(last_battery_change_date)},
      {content: "Próximo Cambio de Batería", background_color: PRIMARY_COLOR}, {content: formated_date(next_battery_change_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_battery_change_date)}]
  end

  def belt_dates_row
    [{content: "Último Cambio de Correa", background_color: PRIMARY_COLOR}, {content: formated_date(last_belt_change_date)},
      {content: "Próximo Cambio de Correa", background_color: PRIMARY_COLOR}, {content: formated_date(next_belt_change_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_belt_change_date)}]
  end

  def last_service_date
    location_equipment.last_service
  end

  def next_service_date
    location_equipment.next_service
  end

  def last_battery_change_date
    location_equipment.last_battery_change
  end

  def next_battery_change_date
    location_equipment.next_battery_change
  end

  def last_belt_change_date
    location_equipment.last_belt_change
  end

  def next_belt_change_date
    location_equipment.next_belt_change
  end

  def date_past?(date)
    return unless date

    (date && date < Date.today) ? "Si" : "No"
  end

  def formated_date(date)
    I18n.l(date, format: "%B %Y") if date
  end

  def ups_foot_notes
    @pdf.move_down 10
    @pdf.text "*Los cambios de baterías de las UPS dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
  end

  def power_unit_foot_notes
    @pdf.move_down 10
    @pdf.text "*Los cambios de baterías y correas de los grupos electrógenos dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
  end
end
