FactoryBot.define do
  factory :tagging do
    tag
    taggable factory: :location_equipment
  end
end
