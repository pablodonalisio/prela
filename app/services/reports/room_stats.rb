class Reports::RoomStats < Reports::Content
  def render
    room_stats
    super
  end

  private

  def room_stats
    table_width = @pdf.bounds.width
    @pdf.table(room_rows, width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      columns(1..2).align = :center
    end
  end

  def room_report_stat
    @report.room_report_stat
  end

  def room_rows
    case equipment.kind
    when "ups" then ups_room_rows
    when "power_unit" then power_unit_room_rows
    when "electrical_panel" then electrical_panel_room_rows
    else
      raise StandardError, "No estan definidas las filas para la sala de este tipo de equipo"
    end
  end

  def ups_room_rows
    [
      [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center, font_style: :bold}],
      [{}, {content: "Valor Observado", font_style: :bold}, {content: "Óptimo", font_style: :bold}],
      [{content: "Estado de la sala"}, {content: room_report_stat.room_status}, {content: "Correcto"}],
      [{content: "Funcionamiento de los aires acondicionados"}, {content: room_report_stat.air_conditioning}, {content: "Correcto"}],
      [{content: "Temperatura"}, {content: "#{room_report_stat.temperature} °C"}, {content: ""}],
      [{content: "Humedad"}, {content: "#{room_report_stat.humidity} %"}, {content: ""}]
    ]
  end

  def power_unit_room_rows
    [
      [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center, font_style: :bold}],
      [{}, {content: "Valor Observado", font_style: :bold}, {content: "Óptimo", font_style: :bold}],
      [{content: "Estado de la sala"}, {content: room_report_stat.room_status}, {content: "Correcto"}]
    ]
  end

  def electrical_panel_room_rows
    [
      [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center, font_style: :bold}],
      [{content: "Limpia y ordenada"}, {content: room_report_stat.clean_and_tidy, colspan: 2}],
      [{content: "Ventilada"}, {content: room_report_stat.ventilated, colspan: 2}],
      [{content: "Libre accesso al tablero"}, {content: room_report_stat.free_access_to_panel, colspan: 2}],
      [{content: "Con llave de ingreso"}, {content: room_report_stat.with_access_key, colspan: 2}]
    ]
  end
end
