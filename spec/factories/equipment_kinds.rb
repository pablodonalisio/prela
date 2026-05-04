FactoryBot.define do
  factory :equipment_kind do
    name { "UPS" }
    fields { {EquipmentKind.generate_field_key => {name: "Brand", type: "string"}} }
  end
end
