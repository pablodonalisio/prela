require "rails_helper"

RSpec.describe EquipmentKind, type: :model do
  it "is valid with valid attributes" do
    equipment_kind = EquipmentKind.new(name: "UPS", fields: {EquipmentKind.generate_field_key => {name: "Brand", type: "string"}})
    expect(equipment_kind).to be_valid
  end

  it "is not valid without a name" do
    equipment_kind = EquipmentKind.new(fields: {EquipmentKind.generate_field_key => {name: "Brand", type: "string"}})
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid without fields" do
    equipment_kind = EquipmentKind.new(name: "Laptop")
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate name" do
    EquipmentKind.create(name: "Laptop", fields: {EquipmentKind.generate_field_key => {name: "Brand", type: "string"}})
    equipment_kind = EquipmentKind.new(name: "Laptop", fields: {EquipmentKind.generate_field_key => {name: "Brand", type: "string"}})
    expect(equipment_kind).not_to be_valid
  end
end
