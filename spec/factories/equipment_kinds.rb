FactoryBot.define do
  factory :equipment_kind do
    name { "UPS" }
    fields { {brand: "string", model: "string"} }
  end
end
