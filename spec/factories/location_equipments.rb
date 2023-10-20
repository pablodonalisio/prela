FactoryBot.define do
  factory :location_equipment do
    zone { "Data Center" }
    floor { 1 }
    location { create(:location) }
    equipment { create(:equipment) }
  end
end
