FactoryBot.define do
  factory :location_equipment do
    zone { "Data Center" }
    floor { 1 }
    location { create(:location) }
    equipment { create(:equipment) }
    details { "Tiene 2 battery pack" }
    serial_number { "lS1051004604" }
    status { "active" }
  end
end
