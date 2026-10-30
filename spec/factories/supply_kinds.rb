FactoryBot.define do
  factory :supply_kind do
    sequence(:name) { |n| "Tipo de insumo #{n}" }
  end
end
