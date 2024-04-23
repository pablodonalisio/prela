class Reports::PdfGenerator < PdfGenerator
  PRIMARY_COLOR = "DACFE8"

  private

  def generate_pdf
    add_header
    add_datetime
    add_equipment_stats
    add_room_stats
    add_observations
    add_images
    add_footer
    super
  end

  def add_header
    @pdf = Reports::Header.new(report, @pdf, client_logo).render
  end

  def add_datetime
    @pdf.move_down 10
    datetime = report&.date || Time.zone.now
    @pdf.table([
      [{content: "FECHA Y HORA: ", font_style: :bold, background_color: PRIMARY_COLOR}, {content: datetime.strftime("%d/%m/%Y %H:%M"), colspan: 2, align: :right}]
    ], width: @pdf.bounds.width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = @pdf.bounds.width / 3
    end
  end

  def add_equipment_stats
    @pdf.move_down 10
    @pdf = Reports::EquipmentStats.new(report, @pdf).render
  end

  def add_room_stats
    @pdf.move_down 10
    @pdf = Reports::RoomStats.new(report, @pdf).render
  end

  def add_observations
    @pdf.move_down 10
    @pdf.table([
      [{content: "OBSERVACIONES", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold}],
      [{content: report.observations, colspan: 3, height: 70, background_color: "f3f3f3"}]
    ], width: @pdf.bounds.width) do
      cells.borders = []
      cells.width = @pdf.bounds.width / 3
    end
  end

  def add_images
    return unless report.images.attached?

    new_page
    @pdf = Reports::Images.new(report, @pdf, report_images).render
  end

  def new_page
    @pdf.start_new_page
    add_header
    @pdf.move_down 10
  end

  def add_footer
    add_contact_info
    add_page_numbers
  end

  def add_contact_info
    @pdf.repeat(:all) do
      @pdf.bounding_box([0, 25], width: @pdf.bounds.width, height: 50) do
        @pdf.font "Helvetica", size: 10
        @pdf.text "Tel: 3512 44 6662 | 3516 70 4660"
        @pdf.text "Email: contacto@prela.com.ar"
        @pdf.text "Dir: Hualfin 758 - Córdoba"
      end
    end
  end

  def add_page_numbers
    @pdf.number_pages "Página <page> de <total>", at: [@pdf.bounds.right - 80, 25], size: 10
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
