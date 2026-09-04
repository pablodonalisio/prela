FactoryBot.define do
  factory :location_equipment_service do
    location_equipment
    service_kind
    interval { 1 }
    interval_unit { :years }
  end
end
