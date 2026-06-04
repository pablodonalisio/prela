require "rails_helper"

RSpec.describe Equipment, type: :model do
  context "validations" do
    let(:equipment) { build(:equipment) }

    it "is valid with valid attributes" do
      expect(equipment).to be_valid
    end

    it "is not valid without a kind" do
      equipment.kind = nil
      expect(equipment).not_to be_valid
    end

    it "is not valid without a name" do
      equipment.name = nil
      expect(equipment).not_to be_valid
    end
  end

  context "associations" do
    let(:equipment) { create(:equipment) }
    let(:supplies) { create_list(:battery, 2) }

    before do
      supplies.each { |supply| equipment.equipment_supplies.create(suppliable: supply) }
    end

    it "should have many supplies" do
      expect(equipment.equipment_supplies.size).to eq(2)
    end

    it "should have one battery" do
      expect(equipment.battery).to be_a(Battery)
    end
  end

  context "name" do
    it "can be set independently of brand and model" do
      equipment = create(:equipment, name: "Custom Name", brand: "Brand", model: "Model")
      expect(equipment.name).to eq("Custom Name")
    end
  end

  context "electrical panel" do
    let(:equipment_kind) { create(:equipment_kind, name: "Electrical Panel") }
    let(:panel) { Equipment.build(kind: "electrical_panel", name: "Nombre del tablero", is_triphase: true, size: "2din", equipment_kind: equipment_kind) }

    it "is valid with electrical panel attributes" do
      expect(panel).to be_valid
    end
  end
end
