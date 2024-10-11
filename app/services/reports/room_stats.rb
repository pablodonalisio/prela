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
      rows(0..1).font_style = :bold
    end
  end

  def room_report_stat
    @report.room_report_stat
  end

  def room_rows
    if equipment.power_unit?
      [
        [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
        [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
        [{content: "Estado de la sala"}, {content: room_report_stat.room_status}, {content: "Correcto"}]
      ]
    else
      [
        [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
        [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
        [{content: "Estado de la sala"}, {content: room_report_stat.room_status}, {content: "Correcto"}],
        [{content: "Funcionamiento de los aires acondicionados"}, {content: room_report_stat.air_conditioning}, {content: "Correcto"}]
      ]
    end
  end
end
