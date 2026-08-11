require "rails_helper"

RSpec.describe LocationEquipmentsHelper, type: :helper do
  describe "#failures_last_year_indicator" do
    it "shows the last-year failure count" do
      location_equipment = build_stubbed(:location_equipment)
      allow(location_equipment).to receive(:failures_last_year_count).and_return(3)

      expect(helper.failures_last_year_indicator(location_equipment)).to eq("Último año: 3")
    end
  end

  describe "#average_failures_indicator" do
    it "returns a dash when average is unavailable" do
      location_equipment = build_stubbed(:location_equipment)
      allow(location_equipment).to receive(:average_failures_per_active_year).and_return(nil)

      expect(helper.average_failures_indicator(location_equipment)).to eq("—")
    end

    it "includes average, active years, and tooltip copy" do
      location_equipment = build_stubbed(:location_equipment)
      allow(location_equipment).to receive_messages(
        average_failures_per_active_year: 2.0,
        active_years_since_metrics_start: 1.5
      )

      html = helper.average_failures_indicator(location_equipment)

      expect(html).to include("Promedio: 2,0 / año en")
      expect(html).to include("1,5 años de actividad")
      expect(html).to include("En Servicio")
      expect(html).to include('data-controller="tooltip"')
    end
  end
end
