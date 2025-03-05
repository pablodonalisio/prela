class Reports::Equipment::ServiceDateStats < Reports::Content
  def render
    @pdf.move_down 10
    service_date_stats
    super
  end

  private

  def service_date_stats
    create_table_with_service_dates
    foot_notes
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
    LocationEquipment::SERVICE_KINDS[equipment.kind].map do |service_kind|
      send("#{service_kind}_dates_row")
    end
  end

  def dates_header
    [{content: "Mantenimiento preventivo", colspan: 6, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}]
  end

  def service_dates_row
    [{content: "Último Servicio", background_color: PRIMARY_COLOR}, {content: formated_date(last_service_date)},
      {content: "Próximo Servicio", background_color: PRIMARY_COLOR}, {content: formated_date(next_service_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_service_date)}]
  end

  def battery_change_dates_row
    [{content: "Último Cambio de Batería", background_color: PRIMARY_COLOR}, {content: formated_date(last_battery_change_date)},
      {content: "Próximo Cambio de Batería", background_color: PRIMARY_COLOR}, {content: formated_date(next_battery_change_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_battery_change_date)}]
  end

  def belt_change_dates_row
    [{content: "Último Cambio de Correa", background_color: PRIMARY_COLOR}, {content: formated_date(last_belt_change_date)},
      {content: "Próximo Cambio de Correa", background_color: PRIMARY_COLOR}, {content: formated_date(next_belt_change_date)},
      {content: "Vencido", background_color: PRIMARY_COLOR}, {content: date_past?(next_belt_change_date)}]
  end

  def last_service_date
    @last_service_date ||= location_equipment.last_service_date(:last_service)
  end

  def next_service_date
    @next_service_date ||= location_equipment.next_service_dates.find_by(kind: "service")&.date
  end

  def last_battery_change_date
    @last_battery_change_date ||= location_equipment.last_service_date(:last_battery_change)
  end

  def next_battery_change_date
    @next_battery_change_date ||= location_equipment.next_service_dates.find_by(kind: "battery_change")&.date
  end

  def last_belt_change_date
    @last_belt_change_date ||= location_equipment.last_service_date(:last_belt_change)
  end

  def next_belt_change_date
    @next_belt_change_date ||= location_equipment.next_service_dates.find_by(kind: "belt_change")&.date
  end

  def date_past?(date)
    return unless date

    (date && date < Date.today) ? "Si" : "No"
  end

  def formated_date(date)
    I18n.l(date, format: "%B %Y") if date
  end

  def foot_notes
    @pdf.move_down 10
    if equipment.ups?
      @pdf.text "*Los cambios de baterías de las UPS dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
    elsif equipment.power_unit?
      @pdf.text "*Los cambios de baterías y correas de los grupos electrógenos dependen del tipo y tiempo de uso, por lo que las próximas fechas son estimativas.", size: 10
    end
  end

  def next_service_dates
    @next_service_dates ||= location_equipment.next_service_dates
  end
end
