class Reports::Content
  PRIMARY_COLOR = "DACFE8"

  def initialize(report, pdf)
    @report = report
    @pdf = pdf
  end

  def render
    @pdf
  end

  private

  def location_equipment
    @location_equipment ||= @report.location_equipment
  end

  def equipment
    @equipment ||= location_equipment.equipment
  end
end
