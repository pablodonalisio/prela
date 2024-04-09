class Reports::RoomStats < Reports::Content
  def render
    room_stats
    super
  end

  private

  def room_stats
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: "SALA", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}],
      [{}, {content: "Valor Observado", font_style: :bold, align: :center}, {content: "Óptimo", font_style: :bold, align: :center}],
      [{content: "Estado de la sala"}, {}, {}],
      [{content: "Funcionamiento de los aires acondicionados"}, {}, {}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end
end
