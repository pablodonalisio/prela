class Reports::Images < Reports::Content
  def initialize(report, pdf, images)
    super(report, pdf)
    @images = images
  end

  def render
    images
    super
  end

  private

  def images
    @images.each_with_index do |image, n|
      table_width = @pdf.bounds.width
      @pdf.table([
        [{content: "FOTO #{n + 1}", background_color: PRIMARY_COLOR, font_style: :bold, align: :center}],
        [{image: image.path, fit: [table_width, 250], position: :center, vposition: :center}]
      ], width: table_width) do
        cells.border_color = PRIMARY_COLOR
      end
    end
  end
end
