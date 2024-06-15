class Reports::Header < Reports::Content
  def initialize(report, pdf, client_logo)
    super(report, pdf)
    @client_logo = client_logo
    @table_width = @pdf.bounds.width
  end

  def render
    header
    super
  end

  private

  def header
    table_width = @pdf.bounds.width
    @pdf.repeat(:all) do
      @pdf.bounding_box([0, @pdf.bounds.top + 110], width: table_width, height: 100) do
        @pdf.table([
          [title],
          [prela_logo, client_image, location_data]
        ], width: table_width) do
          cells.border_color = PRIMARY_COLOR
          cells.width = table_width / 3
        end
      end
    end
  end

  def title
    {content: "INFORME DE CONTROL", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}
  end

  def prela_logo
    {image: Rails.root.join("app/assets/images/prela_logotipo-1.png"), fit: [100, 50], position: :center}
  end

  def client_image
    {image: @client_logo.path, fit: [100, 50], position: :center}
  end

  def location_data
    @pdf.make_table([
      [{content: "Sede: ", font_style: :bold}, location_equipment.location.name],
      [{content: "Piso: ", font_style: :bold}, location_equipment.floor],
      [{content: "Sala: ", font_style: :bold}, location_equipment.zone]
    ], cell_style: {border_width: 0, padding: 1, height: 20, overflow: :shrink_to_fit}, width: @table_width / 3)
  end
end
