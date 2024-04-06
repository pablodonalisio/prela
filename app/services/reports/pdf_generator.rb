class Reports::PdfGenerator < PdfGenerator
  PRIMARY_COLOR = "DACFE8"

  private

  def generate_pdf
    @pdf = Reports::Header.new(report, @pdf, client_logo).render
    super
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
