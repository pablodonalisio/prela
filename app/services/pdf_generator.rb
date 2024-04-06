class PdfGenerator
  attr_reader :pdf, :error

  def initialize(data)
    @data = data
    @success = false
    @pdf = Prawn::Document.new
  end

  def self.call(data)
    new(data).call
  end

  def call
    begin
      generate_pdf
      @success = true
      cleanup
    rescue => e
      @error = e
    end
    self
  end

  def success?
    @success
  end

  private

  def generate_pdf
    @pdf = @pdf.render
  end

  def cleanup
  end
end
