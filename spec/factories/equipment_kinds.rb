FactoryBot.define do
  factory :equipment_kind do
    sequence(:name) { |n| "Tipo de activo #{n}" }
    generic_fields { {"brand" => {name: "Marca", type: "string"}} }
    specific_fields { {} }

    trait :ups do
      legacy_kind { "ups" }
      name { "UPS" }
    end

    trait :power_unit do
      legacy_kind { "power_unit" }
      name { "Grupo Electrógeno" }
    end

    trait :electrical_panel do
      legacy_kind { "electrical_panel" }
      name { "Tablero Eléctrico" }
    end

    trait :building do
      legacy_kind { "building" }
      name { "Edificio" }
    end

    trait :with_specific_fields do
      specific_fields { {"serial_number" => {name: "Número de serie", type: "string"}} }
    end
  end
end
