require "rails_helper"

RSpec.describe ServiceDate, type: :model do
  describe ".overdue_next_service_dates" do
    let(:location_equipment) { create(:location_equipment) }
    let(:older_service_date) { create(:service_date, location_equipment:, kind: :service, date: 4.months.ago) }
    let(:overdue_service_date) { create(:service_date, location_equipment:, kind: :service, date: 2.months.from_now) }

    let(:location_equipment2) { create(:location_equipment) }
    let(:overdue_battery_change_date) { create(:service_date, location_equipment: location_equipment2, kind: :battery_change, date: 1.month.ago) }

    let(:location_equipment_with_no_overdue) { create(:location_equipment) }
    let(:service_date_with_no_overdue) { create(:service_date, location_equipment: location_equipment_with_no_overdue, kind: :service, date: 4.months.from_now) }

    let(:result) { ServiceDate.overdue_next_service_dates }

    before do
      location_equipment
      location_equipment2

      # Delete other service dates to ensure only the latest per kind is considered
      ServiceDate.delete_all
    end

    it "returns service dates that are overdue within the next 3 months" do
      older_service_date
      overdue_service_date
      overdue_battery_change_date
      service_date_with_no_overdue

      expect(result).to include(overdue_service_date, overdue_battery_change_date)
      expect(result).not_to include(service_date_with_no_overdue, older_service_date)
    end
  end

  describe ".next_service_dates" do
    let(:location_equipment) { create(:location_equipment) }

    let(:older_service_date) { create(:service_date, location_equipment:, kind: :service, date: 4.months.ago) }
    let(:newer_service_date) { create(:service_date, location_equipment:, kind: :service, date: 8.months.from_now) }
    let(:battery_change_date) { create(:service_date, location_equipment:, kind: :battery_change, date: 2.months.ago) }

    let(:result) { ServiceDate.next_service_dates }

    before do
      location_equipment

      # Delete other service dates to ensure only the latest per kind is considered
      ServiceDate.delete_all
    end

    it "returns the most recent service date for each kind per location equipment" do
      older_service_date
      newer_service_date
      battery_change_date
      expect(result.map(&:id)).to include(newer_service_date.id, battery_change_date.id)
      expect(result.map(&:id)).not_to include(older_service_date.id)
    end
  end
end
