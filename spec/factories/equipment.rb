FactoryBot.define do
  factory :equipment do
    transient do
      legacy_kind { "ups" }
    end

    brand { "APC" }
    model { "Smart-RT 10000" }
    name { "#{brand} - #{model}" }
    technical_model { "SURT10000XL" }
    kva { 10 }
    manual { "https://www.apc.com/ar/es/product/SURT10000XLT/unidad-smartups-rt-de-apc-10-000-va-y-208v/" }
    equipment_kind { EquipmentKind.find_by(legacy_kind: legacy_kind) || create(:equipment_kind, legacy_kind.to_sym) }
    field_values do
      {
        "technical_model" => technical_model,
        "kva" => kva,
        "manual" => manual
      }
    end

    trait :ups do
      legacy_kind { "ups" }
    end

    trait :power_unit do
      legacy_kind { "power_unit" }
    end

    trait :electrical_panel do
      legacy_kind { "electrical_panel" }
    end

    trait :building do
      legacy_kind { "building" }
    end
  end
end
