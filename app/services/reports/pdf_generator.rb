class Reports::PdfGenerator < PdfGenerator
  PRIMARY_COLOR = "DACFE8"

  private

  def generate_pdf
    add_header_to_pdf
    @pdf.move_down 10
    add_datetime_to_pdf
    @pdf.move_down 10
    add_equipment_stats_to_pdf
    super
  end

  def add_header_to_pdf
    @pdf = Reports::Header.new(report, @pdf, client_logo).render
  end

  def add_datetime_to_pdf
    datetime = report&.created_at || Time.zone.now
    @pdf.table([
      [{content: "FECHA Y HORA: ", font_style: :bold, background_color: PRIMARY_COLOR}, {content: datetime.strftime("%d/%m/%Y %H:%M"), colspan: 2, align: :right}]
    ], width: @pdf.bounds.width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = @pdf.bounds.width / 3
    end
  end

  def add_equipment_stats_to_pdf
    @pdf = Reports::EquipmentStats.new(report, @pdf).render
  end

  def report
    @data
  end

  def location_equipment
    report.location_equipment
  end

  def client_logo
    @client_avatar_temp_file = create_tempfile(location_equipment.client.avatar)
  end
end
