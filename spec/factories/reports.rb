FactoryBot.define do
  factory :report do
    location_equipment { create(:location_equipment) }
    observations { "Some observation" }
    date { Time.now.beginning_of_day }
  end
end
