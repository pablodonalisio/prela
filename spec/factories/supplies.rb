FactoryBot.define do
  factory :supply do
    supply_kind
    sequence(:name) { |n| "Insumo #{n}" }
    description { "Descripción del insumo" }
    reference_url { "https://example.com/insumo" }
  end
end
