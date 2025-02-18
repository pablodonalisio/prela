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

    it "returns service dates for ups" do
      expect(ups.service_dates).to eq(%i[last_battery_change next_battery_change])
    end

    it "returns service dates for power unit" do
      expect(power_unit.service_dates).to eq(%i[last_service next_service last_battery_change next_battery_change last_belt_change next_belt_change])
    end

    it "raises an error if service dates are not defined" do
      allow(undefined_equipment.equipment).to receive(:kind).and_return("undefined")

      expect { undefined_equipment.service_dates }.to raise_error(RuntimeError, "No estan definidas las fechas de servicio para el equipo undefined")
    end
  end
end
