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

  context "scopes" do
    let!(:location_equipment1) { create(:location_equipment) }
    let!(:location_equipment2) { create(:location_equipment) }

    it "returns location equipments by client ids" do
      expect(LocationEquipment.by_client_ids([location_equipment1.location.client_id]).count).to eq(1)
    end

    it "returns location equipments by location ids" do
      expect(LocationEquipment.by_location_ids([location_equipment1.location_id]).count).to eq(1)
    end
  end

  context "delegations" do
    let(:location_equipment) { create(:location_equipment) }

    it "delegates avatar to equipment" do
      expect(location_equipment.avatar).to eq(location_equipment.equipment.avatar)
    end

    it "delegates model to equipment" do
      expect(location_equipment.model).to eq(location_equipment.equipment.model)
    end

    it "delegates client to location" do
      expect(location_equipment.client).to eq(location_equipment.location.client)
    end
  end
end
