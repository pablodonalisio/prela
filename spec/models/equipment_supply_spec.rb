require "rails_helper"

RSpec.describe EquipmentSupply, type: :model do
  context "validations" do
    let(:equipment_supply) { build(:equipment_supply) }

    it "is valid with valid attributes" do
      expect(equipment_supply).to be_valid
    end

    it "is not valid without a supply" do
      equipment_supply.supply = nil
      expect(equipment_supply).not_to be_valid
    end

    it "is not valid without a location equipment" do
      equipment_supply.location_equipment = nil
      expect(equipment_supply).not_to be_valid
    end

    it "requires a quantity greater than zero" do
      expect(build(:equipment_supply, quantity: nil)).not_to be_valid
      expect(build(:equipment_supply, quantity: 0)).not_to be_valid
      expect(build(:equipment_supply, quantity: 1.5)).not_to be_valid
      expect(build(:equipment_supply, quantity: 2)).to be_valid
    end

    it "allows one row per supply on a location equipment" do
      existing = create(:equipment_supply)

      duplicate = build(:equipment_supply, location_equipment: existing.location_equipment, supply: existing.supply)
      other_supply = build(:equipment_supply, location_equipment: existing.location_equipment)

      expect(duplicate).not_to be_valid
      expect(other_supply).to be_valid
    end
  end

  context "associations" do
    let(:equipment_supply) { create(:equipment_supply) }

    it "belongs to a location equipment and a supply" do
      expect(equipment_supply.location_equipment).to be_a(LocationEquipment)
      expect(equipment_supply.supply).to be_a(Supply)
    end
  end
end
