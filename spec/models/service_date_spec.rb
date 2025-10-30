require "rails_helper"

RSpec.describe ServiceDate, type: :model do
  before { allow_any_instance_of(LocationEquipment).to receive(:create_next_service_dates).and_return(nil) } # To prevent callbacks during tests

  describe ".overdue_next_service_dates" do
    let(:location_equipment) { create(:location_equipment) }
    let!(:older_service_date) { create(:service_date, location_equipment:, kind: :service, date: 4.months.ago) }
    let!(:overdue_service_date) { create(:service_date, location_equipment:, kind: :service, date: 2.months.from_now) }

    let(:location_equipment2) { create(:location_equipment) }
    let!(:overdue_battery_change_date) { create(:service_date, location_equipment: location_equipment2, kind: :battery_change, date: 1.month.ago) }

    let(:location_equipment_with_no_overdue) { create(:location_equipment) }
    let!(:service_date_with_no_overdue) { create(:service_date, location_equipment: location_equipment_with_no_overdue, kind: :service, date: 4.months.from_now) }

    let(:result) { ServiceDate.overdue_next_service_dates }

    it "returns service dates that are overdue within the next 3 months" do
      expect(result).to include(overdue_service_date, overdue_battery_change_date)
      expect(result).not_to include(service_date_with_no_overdue, older_service_date)
    end
  end

  describe ".next_service_dates" do
    let(:location_equipment) { create(:location_equipment) }

    let!(:older_service_date) { create(:service_date, location_equipment:, kind: :service, date: 4.months.ago) }
    let!(:newer_service_date) { create(:service_date, location_equipment:, kind: :service, date: 8.months.from_now) }
    let!(:battery_change_date) { create(:service_date, location_equipment:, kind: :battery_change, date: 2.months.ago) }

    let(:result) { ServiceDate.next_service_dates }

    it "returns the most recent service date for each kind per location equipment" do
      expect(result.map(&:id)).to include(newer_service_date.id, battery_change_date.id)
      expect(result.map(&:id)).not_to include(older_service_date.id)
    end
  end

  describe "filtering" do
    let(:location_equipment) { create(:location_equipment, location: create(:location, client: client_with_services)) }
    let(:client_with_services) { create(:client) }
    let!(:client_without_services) { create(:client) }
    let!(:service) { create(:service_date, location_equipment:, kind: :service, date: 1.month.ago) }
    let!(:battery_change) { create(:service_date, location_equipment:, kind: :battery_change, date: 2.months.ago) }
    let(:filtered_by_kind) { ServiceDate.by_kind(:service) }
    let(:filtered_by_client_with_services) { ServiceDate.by_client_id(client_with_services.id) }
    let(:filtered_by_client_without_services) { ServiceDate.by_client_id(client_without_services.id) }

    it "filters by kind" do
      expect(filtered_by_kind).to include(service)
      expect(filtered_by_kind).not_to include(battery_change)
    end

    it "filters by client" do
      expect(filtered_by_client_with_services).to include(service, battery_change)
      expect(filtered_by_client_without_services).to be_empty
    end
  end
end
