class Reports::RoomStats < Reports::Content
  def render
    room_stats
    super
  end

  private

  def room_stats
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
      [{content: "Estado de la sala"}, {}, {content: "Correcto"}],
      [{content: "Funcionamiento de los aires acondicionados"}, {}, {content: "Correcto"}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      columns(1..2).align = :center
      rows(0..1).font_style = :bold
    end
  end
end
