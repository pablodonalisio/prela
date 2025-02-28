require "rails_helper"

RSpec.describe LocationEquipment, type: :model do
  context "associations" do
    let(:location_equipment) { create(:location_equipment) }

    it "belongs to a location" do
      expect(location_equipment.location).to be_a(Location)
    end

    it "belongs to an equipment" do
      expect(location_equipment.equipment).to be_a(Equipment)
    end

    it "has many equipment supplies" do
      create_list(:equipment_supply, 3, equipmentable: location_equipment)
      expect(location_equipment.equipment_supplies.size).to eq(3)
    end

    it "has one equipment battery" do
      create(:equipment_supply, equipmentable: location_equipment)
      expect(location_equipment.equipment_battery).to be_a(EquipmentSupply)
    end

    it "has one battery through equipment battery" do
      battery = create(:battery)
      create(:equipment_supply, equipmentable: location_equipment, suppliable: battery)
      expect(location_equipment.battery).to eq(battery)
    end
  end

  context "filter scopes" do
    let!(:location_equipment1) { create(:location_equipment, status: LocationEquipment.statuses.keys[0]) }
    let!(:location_equipment2) { create(:location_equipment, status: LocationEquipment.statuses.keys[1]) }

    it "returns location equipments by client ids" do
      expect(LocationEquipment.by_client_ids([location_equipment1.location.client_id]).count).to eq(1)
    end

    it "returns location equipments by location ids" do
      expect(LocationEquipment.by_location_ids([location_equipment1.location_id]).count).to eq(1)
    end

    it "returns location equipments by status" do
      expect(LocationEquipment.by_status(LocationEquipment.statuses.keys[0]).count).to eq(1)
    end
  end

  context "maintenance scopes" do
    let(:ups) { create(:equipment, kind: :ups) }
    let(:power_unit) { create(:equipment, kind: :power_unit) }

    let!(:ups_with_overdue_service) { create(:location_equipment, next_service: Date.yesterday, equipment: ups) }
    let!(:ups_with_overdue_battery_change) { create(:location_equipment, next_battery_change: Date.yesterday, equipment: ups) }
    let!(:ups_without_overdue_maintenance) { create(:location_equipment, next_service: Date.tomorrow, next_battery_change: Date.tomorrow, equipment: ups) }

    let!(:power_unit_with_overdue_service) { create(:location_equipment, next_service: Date.yesterday, equipment: power_unit) }
    let!(:power_unit_with_overdue_battery_change) { create(:location_equipment, next_battery_change: Date.yesterday, equipment: power_unit) }
    let!(:power_unit_without_overdue_maintenance) { create(:location_equipment, next_service: Date.tomorrow, next_battery_change: Date.tomorrow, equipment: power_unit) }

    let(:ups_with_overdue_maintenance) { LocationEquipment.ups_with_overdue_maintenance }
    let(:power_units_with_overdue_maintenance) { LocationEquipment.power_units_with_overdue_maintenance }

    it "return ups with overdue maintenance" do
      expect(ups_with_overdue_maintenance.count).to eq(1)
      expect(ups_with_overdue_maintenance).to include(ups_with_overdue_battery_change)
    end

    it "return power units with overdue maintenance" do
      expect(power_units_with_overdue_maintenance.count).to eq(2)
      expect(power_units_with_overdue_maintenance).to include(power_unit_with_overdue_service, power_unit_with_overdue_battery_change)
    end
  end

  context "methods" do
    let(:ups) { create(:location_equipment, equipment: create(:equipment, kind: :ups)) }
    let(:power_unit) { create(:location_equipment, equipment: create(:equipment, kind: :power_unit)) }
    let(:undefined_equipment) { create(:location_equipment) }

    context "next_service_dates" do
      let!(:location_equipment) do
        location_equipment = create(:location_equipment)
        location_equipment.service_dates.destroy_all # Remove default next service dates created by after_create callback
        location_equipment
      end
      let!(:older_battery_change) { create(:service_date, kind: :battery_change, date: 2.years.ago, location_equipment: location_equipment) }
      let!(:older_service) { create(:service_date, kind: :service, date: 1.years.ago, location_equipment: location_equipment) }
      let!(:older_belt_change) { create(:service_date, kind: :belt_change, date: 5.years.ago, location_equipment: location_equipment) }
      let!(:next_battery_change) { create(:service_date, kind: :battery_change, date: Date.current, location_equipment: location_equipment) }
      let!(:next_service) { create(:service_date, kind: :service, date: Date.current, location_equipment: location_equipment) }
      let!(:next_belt_change) { create(:service_date, kind: :belt_change, date: Date.current, location_equipment: location_equipment) }

      it "returns next service dates for location equipment" do
        expect(location_equipment.next_service_dates.map { |sd| sd.date.to_date }).to all(eq(Date.current))
        expect(location_equipment.next_service_dates.size).to eq(ServiceDate.kinds.size)
      end
    end

    context "last_service_date" do
      let(:location_equipment) { create(:location_equipment) }
      let!(:activity) { create(:activity, kind: Activity::BATTERY_CHANGE, date: Date.today, location_equipment: location_equipment) }

      it "returns last service date" do
        expect(location_equipment.last_service_date(:last_battery_change).to_date).to eq(Date.today)
      end
    end

    context "create_next_service_dates" do
      let(:service_kinds) { %i[service battery_change belt_change] }

      it "creates first next service dates after location equipment creation" do
        freeze_time

        expect(power_unit.next_service_dates.size).to eq(ServiceDate.kinds.size)
        expect(power_unit.next_service_dates.service.first.date).to eq(1.year.from_now)
        expect(power_unit.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
        expect(power_unit.next_service_dates.belt_change.first.date).to eq(5.years.from_now)
      end

      it "creates new next service dates for power unit from specific time" do
        freeze_time
        power_unit.create_next_service_dates(Time.current, service_kinds)

        expect(power_unit.next_service_dates.size).to eq(ServiceDate.kinds.size)
        expect(power_unit.next_service_dates.service.first.date).to eq(1.year.from_now)
        expect(power_unit.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
        expect(power_unit.next_service_dates.belt_change.first.date).to eq(5.years.from_now)
      end

      it "creates new next service dates for specific kind of equipment" do
        freeze_time
        ups.create_next_service_dates(Time.current)

        expect(ups.next_service_dates.size).to eq(1)
        expect(ups.next_service_dates.battery_change.first.date).to eq(2.years.from_now)
      end
    end
  end
end
