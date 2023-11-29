require "rails_helper"

RSpec.describe EquipmentSupply, type: :model do
  context "validations" do
    let(:equipment_supply) { build(:equipment_supply) }

    it "is valid with valid attributes" do
      expect(equipment_supply).to be_valid
    end

    it "is not valid without a suppliable" do
      equipment_supply.suppliable = nil
      expect(equipment_supply).not_to be_valid
    end
  end

  context "associations" do
    let(:equipment_supply) { create(:equipment_supply) }

    it "can belong to a battery" do
      expect(equipment_supply.suppliable).to be_a(Battery)
    end
  end

  context "delegations" do
    let(:equipment_supply) { create(:equipment_supply) }

    it "delegates avatar to suppliable" do
      expect(equipment_supply.avatar).to eq(equipment_supply.suppliable.avatar)
    end

    it "delegates model to suppliable" do
      expect(equipment_supply.model).to eq(equipment_supply.suppliable.model)
    end

    it "delegates voltage to suppliable" do
      expect(equipment_supply.voltage).to eq(equipment_supply.suppliable.voltage)
    end

    it "delegates amps to suppliable" do
      expect(equipment_supply.amps).to eq(equipment_supply.suppliable.amps)
    end
  end

  context "scopes" do
    let(:equipment_supply) { create(:equipment_supply) }

    xit "returns batteries with the batteries scope" do
      create_list(:equipment_supply, 3)
      create(:equipment_supply, suppliable: create(:other_suppliable))

      expect(EquipmentSupply.batteries.count).to eq(3)
    end
  end
end
