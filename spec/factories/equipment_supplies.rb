FactoryBot.define do
  factory :equipment_supply do
    equipment { create(:equipment) }
    supply { create(:battery) }
    quantity { 1 }
  end
end
