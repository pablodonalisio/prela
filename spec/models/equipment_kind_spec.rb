require "rails_helper"

RSpec.describe EquipmentKind, type: :model do
  it "is valid with generic fields" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).to be_valid
  end

  it "is not valid without a name" do
    equipment_kind = EquipmentKind.new(
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
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
      generic_fields: {"brand" => {name: "Marca", type: "string"}},
      specific_fields: {}
    )
    expect(equipment_kind).to be_valid
  end

  it "is not valid with a duplicate name" do
    EquipmentKind.create!(
      name: "Laptop",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "Laptop",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate name ignoring case" do
    EquipmentKind.create!(
      name: "Laptop",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "LAPTOP",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:name]).to be_present
  end

  it "is not valid with a duplicate name ignoring accents" do
    EquipmentKind.create!(
      name: "Tablero Eléctrico",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "tablero electrico",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
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
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate legacy_kind" do
    EquipmentKind.create!(
      name: "UPS",
      legacy_kind: "ups",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    equipment_kind = EquipmentKind.new(
      name: "Another UPS",
      legacy_kind: "ups",
      generic_fields: {"brand" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with an invalid field type" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"brand" => {name: "Marca", type: "invalid"}}
    )
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with duplicate generic field names" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {
        "brand" => {name: "Marca", type: "string"},
        "model" => {name: "Marca", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:generic_fields]).to include("El nombre de campo 'Marca' ya está en uso.")
  end

  it "is not valid with duplicate generic field names ignoring case" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {
        "brand" => {name: "Marca", type: "string"},
        "model" => {name: "MARCA", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:generic_fields]).to be_present
  end

  it "is not valid with duplicate specific field names" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"brand" => {name: "Marca", type: "string"}},
      specific_fields: {
        "serial_number" => {name: "Número de serie", type: "string"},
        "code" => {name: "Número de serie", type: "string"}
      }
    )
    expect(equipment_kind).not_to be_valid
    expect(equipment_kind.errors[:specific_fields]).to include("El nombre de campo 'Número de serie' ya está en uso.")
  end

  it "is valid with the same field name in generic and specific fields" do
    equipment_kind = EquipmentKind.new(
      name: "UPS",
      generic_fields: {"brand" => {name: "Marca", type: "string"}},
      specific_fields: {"serial_number" => {name: "Marca", type: "string"}}
    )
    expect(equipment_kind).to be_valid
  end
end
