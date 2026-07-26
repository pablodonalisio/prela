require "rails_helper"

RSpec.describe EquipmentKind, type: :model do
  it "is valid with generic fields" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).to be_valid
  end

  it "is not valid without a name" do
    equipment_kind = EquipmentKind.new(
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid without generic fields" do
    equipment_kind = EquipmentKind.new(name: "Laptop")
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:generic_fields]).to be_present
  end

  it "is valid with empty specific fields" do
    equipment_kind = EquipmentKind.new(
      name: "Laptop",
      generic_fields: {"kva" => {name: "Kva", type: "float"}},
      specific_fields: {}
    )
    expect(equipment_kind).to be_valid
  end

  it "is not valid with a duplicate name" do
    EquipmentKind.create!(
      name: "Laptop",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "Laptop",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case" do
    EquipmentKind.create!(
      name: "Laptop",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "LAPTOP",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:name]).to be_present
  end

  it "is not valid with a duplicate name ignoring accents" do
    EquipmentKind.create!(
      name: "Tablero Eléctrico",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "tablero electrico",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:name]).to be_present
  end

  describe ".normalize_name" do
    it "downcases, strips, and removes accents" do
      expect(described_class.normalize_name("  Tablero Eléctrico  ")).to eq("tablero electrico")
    end
  end

  it "is not valid with an invalid legacy_kind" do
    equipment_kind = EquipmentKind.new(
      name: "Custom",
      legacy_kind: "invalid",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate legacy_kind" do
    EquipmentKind.create!(
      name: "UPS",
      legacy_kind: "ups",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "Another UPS",
      legacy_kind: "ups",
      generic_fields: {"kva" => {name: "Kva", type: "float"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with an invalid field type" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"kva" => {name: "Kva", type: "invalid"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with duplicate generic field names" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {
        "kva" => {name: "Kva", type: "float"},
        "manual" => {name: "Kva", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:generic_fields]).to include("El nombre de campo 'Kva' ya está en uso.")
  end

  it "is not valid with duplicate generic field names ignoring case" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {
        "kva" => {name: "Kva", type: "float"},
        "manual" => {name: "KVA", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:generic_fields]).to be_present
  end

  it "is not valid with duplicate specific field names" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"kva" => {name: "Kva", type: "float"}},
      specific_fields: {
        "form_link" => {name: "Link al formulario", type: "string"},
        "more_info" => {name: "Link al formulario", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:specific_fields]).to include("El nombre de campo 'Link al formulario' ya está en uso.")
  end

  it "is valid with the same field name in generic and specific fields" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"kva" => {name: "Kva", type: "float"}},
      specific_fields: {"form_link" => {name: "Kva", type: "string"}}
    )
    expect(equipment_kind).to be_valid
  end

  describe "field count helpers" do
    it "counts associated kept equipments" do
      equipment_kind = EquipmentKind.create!(
        name: "UPS",
        generic_fields: {"1" => {name: "Marca", type: "string"}}
      )
      create(:equipment, equipment_kind: equipment_kind)
      create(:equipment, equipment_kind: equipment_kind).discard

      expect(equipment_kind.equipments_count).to eq(1)
    end
  end

  describe "soft delete" do
    it "allows reusing a name after discard" do
      equipment_kind = EquipmentKind.create!(
        name: "Laptop",
        generic_fields: {"kva" => {name: "Kva", type: "float"}}
      )
      equipment_kind.discard

      reused = EquipmentKind.new(
        name: "Laptop",
        generic_fields: {"kva" => {name: "Kva", type: "float"}}
      )

      expect(reused).to be_valid
      expect(reused.save).to be(true)
    end

    it "allows reusing a legacy_kind after discard" do
      equipment_kind = EquipmentKind.create!(
        name: "UPS Kind",
        legacy_kind: "ups",
        generic_fields: {"kva" => {name: "Kva", type: "float"}}
      )
      equipment_kind.discard

      reused = EquipmentKind.new(
        name: "Another UPS",
        legacy_kind: "ups",
        generic_fields: {"kva" => {name: "Kva", type: "float"}}
      )

      expect(reused).to be_valid
    end
  end
end

