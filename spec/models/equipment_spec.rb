require "rails_helper"

RSpec.describe Equipment, type: :model do
  context "validations" do
    let(:equipment) { build(:equipment) }

    it "is valid with valid attributes" do
      expect(equipment).to be_valid
    end

    it "is not valid without an equipment_kind" do
      equipment.equipment_kind = nil
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

  context "field_values" do
    it "defaults to an empty hash" do
      equipment = Equipment.new
      expect(equipment.field_values).to eq({})
    end
  end

  context "legacy_kind" do
    it "returns legacy_kind from equipment_kind" do
      equipment_kind = create(:equipment_kind, :ups)
      equipment = Equipment.new(equipment_kind: equipment_kind, name: "Test")
      expect(equipment.legacy_kind).to eq("ups")
      expect(equipment.kind).to eq("ups")
      expect(equipment.ups?).to be true
    end
  end

  context "electrical panel" do
    let(:equipment_kind) do
      create(:equipment_kind,
        legacy_kind: "electrical_panel",
        name: "Tablero Eléctrico",
        generic_fields: {
          "is_triphase" => {"name" => "Trifásica", "type" => "boolean"},
          "size" => {"name" => "Tamaño", "type" => "string"}
        })
    end
    let(:panel) do
      Equipment.build(
        name: "Nombre del tablero",
        field_values: {"is_triphase" => true, "size" => "2din"},
        equipment_kind: equipment_kind
      )
    end

    it "is valid with electrical panel attributes" do
      expect(panel).to be_valid
    end
  end

  describe ".visible" do
    it "excludes discarded equipment and equipment with discarded kinds" do
      visible_equipment = create(:equipment, equipment_kind: create(:equipment_kind))
      discarded_equipment = create(:equipment, equipment_kind: create(:equipment_kind))
      discarded_equipment.discard
      equipment_with_discarded_kind = create(:equipment, equipment_kind: create(:equipment_kind))
      equipment_with_discarded_kind.equipment_kind.discard

      expect(Equipment.visible).to include(visible_equipment)
      expect(Equipment.visible).not_to include(discarded_equipment)
      expect(Equipment.visible).not_to include(equipment_with_discarded_kind)
      expect(equipment_with_discarded_kind.reload).to be_kept
    end
  end
end


