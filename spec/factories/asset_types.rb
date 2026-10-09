FactoryBot.define do
  factory :asset_type do
    sequence(:name) { |n| "Tipo de activo #{n}" }
  end
end
