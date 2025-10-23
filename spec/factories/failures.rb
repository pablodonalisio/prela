FactoryBot.define do
  factory :failure do
    description { "Falla #{rand(1000..9999)}" }
    date { "2025-10-23" }
    location_equipment
  end
end
