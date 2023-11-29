FactoryBot.define do
  factory :equipment_supply do
    equipmentable { create(:equipment) }
    suppliable { create(:battery) }
    quantity { 1 }
  end
end
