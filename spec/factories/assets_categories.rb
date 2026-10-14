FactoryBot.define do
  factory :assets_category do
    sequence(:name) { |n| "Categoría #{n}" }
  end
end
