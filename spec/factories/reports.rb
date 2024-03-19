FactoryBot.define do
  factory :report do
    location_equipment { create(:location_equipment) }
    observations { "Some observation" }
  end
end
