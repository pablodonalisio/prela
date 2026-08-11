FactoryBot.define do
  factory :comment do
    description { "Comentario #{rand(1000..9999)}" }
    location_equipment
  end
end
