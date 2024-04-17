class Reports::PdfGenerator < PdfGenerator
  PRIMARY_COLOR = "DACFE8"

  private

  def generate_pdf
    add_header_to_pdf
    add_datetime_to_pdf
    add_equipment_stats_to_pdf
    add_room_stats_to_pdf
    add_observations_to_pdf
    add_images_to_pdf
    super
  end

  def add_header_to_pdf
    @pdf = Reports::Header.new(report, @pdf, client_logo).render
  end

  def add_datetime_to_pdf
    @pdf.move_down 10
    datetime = report&.created_at || Time.zone.now
    @pdf.table([
      [{content: "FECHA Y HORA: ", font_style: :bold, background_color: PRIMARY_COLOR}, {content: datetime.strftime("%d/%m/%Y %H:%M"), colspan: 2, align: :right}]
    ], width: @pdf.bounds.width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = @pdf.bounds.width / 3
    end
  end

  def add_equipment_stats_to_pdf
    @pdf.move_down 10
    @pdf = Reports::EquipmentStats.new(report, @pdf).render
  end

  def add_room_stats_to_pdf
    @pdf.move_down 10
    @pdf = Reports::RoomStats.new(report, @pdf).render
  end

  def add_observations_to_pdf
    @pdf.move_down 10
    @pdf.table([
      [{content: "OBSERVACIONES", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold}],
      [{content: report.observations, colspan: 3, height: 100, background_color: "f3f3f3"}]
    ], width: @pdf.bounds.width) do
      cells.borders = []
      cells.width = @pdf.bounds.width / 3
    end
  end

  def add_images_to_pdf
    return unless report.images.attached?

    new_page
    @pdf = Reports::Images.new(report, @pdf, report_images).render
  end

  def new_page
    @pdf.start_new_page
    add_header_to_pdf
    @pdf.move_down 10
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

  def report_images
    images = []
    report.images.each { |image| images << create_tempfile(image) }
    images
  end
end
