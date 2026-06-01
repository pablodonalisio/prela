FactoryBot.define do
  factory :equipment_kind do
    sequence(:name) { |n| "Tipo de activo #{n}" }
    generic_fields { {"brand" => {name: "Marca", type: "string"}} }
    specific_fields { {} }

    trait :ups do
      legacy_kind { "ups" }
      name { "UPS" }
    end

    trait :with_specific_fields do
      specific_fields { {"serial_number" => {name: "Número de serie", type: "string"}} }
    end
  end
end
