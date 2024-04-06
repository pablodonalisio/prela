class Reports::PdfGenerator < PdfGenerator
  PRIMARY_COLOR = "DACFE8"

  private

  def generate_pdf
    header
    super
  end

  def report
    @data
  end

  def header
    table_width = pdf.bounds.width
    pdf.table([
      [title],
      [prela_logo, client_logo, location_data]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end

  def title
    {content: "INFORME DE CONTROL", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}
  end

  def prela_logo
    {image: Rails.root.join("app/assets/images/prela_logotipo-1.png"), fit: [100, 50], position: :center}
  end

  def client_logo
    avatar = location_equipment.client.avatar
    @client_avatar_temp_file = Tempfile.new(["avatar", File.extname(avatar.filename.to_s)], Rails.root.join("tmp"))
    @client_avatar_temp_file.binmode
    @client_avatar_temp_file.write(avatar.download)
    @client_avatar_temp_file.rewind
    {image: @client_avatar_temp_file.path, fit: [100, 50], position: :center}
  end

  def location_data
    pdf.make_table([
      [{content: "Sede: ", font_style: :bold}, location_equipment.location.name],
      [{content: "Piso: ", font_style: :bold}, location_equipment.floor],
      [{content: "Sala: ", font_style: :bold}, location_equipment.zone]
    ], cell_style: {border_width: 0, padding: 1})
  end

  def location_equipment
    report.location_equipment
  end

  def cleanup
    @client_avatar_temp_file.close
    @client_avatar_temp_file&.unlink
  end
end
