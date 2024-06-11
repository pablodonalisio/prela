class PdfGenerator
  attr_reader :pdf, :error

  def initialize(data)
    @data = data
    @success = false
    @pdf = Prawn::Document.new
    @tempfiles = []
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
      @error = e.message.truncate(200) + " in #{Rails.backtrace_cleaner.clean(e.backtrace).first}"
      Rails.logger.error @error
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

  def create_tempfile(file)
    tempfile = Tempfile.new(["report", File.extname(file.filename.to_s)], Rails.root.join("tmp"))
    tempfile.binmode
    tempfile.write(file.download)
    tempfile.rewind
    @tempfiles << tempfile
    tempfile
  end

  def cleanup
    @tempfiles.each do |tempfile|
      tempfile.close
      tempfile&.unlink
    end
  end
end
