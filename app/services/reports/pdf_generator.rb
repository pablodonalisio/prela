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
    avatar = location_equipment.client.avatar
    @client_avatar_temp_file = Tempfile.new(["avatar", File.extname(avatar.filename.to_s)], Rails.root.join("tmp"))
    @client_avatar_temp_file.binmode
    @client_avatar_temp_file.write(avatar.download)
    @client_avatar_temp_file.rewind
    @client_avatar_temp_file
  end

  def cleanup
    @client_avatar_temp_file.close
    @client_avatar_temp_file&.unlink
  end
end
