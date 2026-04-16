require "rails_helper"

RSpec.describe EquipmentKind, type: :model do
  it "is valid with valid attributes" do
    equipment_kind = EquipmentKind.new(name: "UPS", fields: {brand: "string", model: "string"})
    expect(equipment_kind).to be_valid
  end

  it "is not valid without a name" do
    equipment_kind = EquipmentKind.new(fields: {brand: "string", model: "string"})
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid without fields" do
    equipment_kind = EquipmentKind.new(name: "Laptop")
    expect(equipment_kind).not_to be_valid
  end

  it "is not valid with a duplicate name" do
    EquipmentKind.create(name: "Laptop", fields: {brand: "string", model: "string"})
    equipment_kind = EquipmentKind.new(name: "Laptop", fields: {brand: "string", model: "string"})
    expect(equipment_kind).not_to be_valid
  end
end
