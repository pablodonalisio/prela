FactoryBot.define do
  factory :contact do
    name { "Juan Pérez" }
    job_position { "Jefe de planta" }
    work_area { "Operaciones" }
    client { association :client }
    reports_to { nil }
    distance_above { 0 }
    email { "juan@example.com" }
    phone { "11-1234-5678" }
    description { "Contacto principal" }

    trait :with_superior do
      reports_to { association :contact, client: client }
      distance_above { 1 }
    end

    trait :with_locations do
      transient do
        locations_count { 2 }
      end

      after(:create) do |contact, evaluator|
        create_list(:location, evaluator.locations_count, client: contact.client).each do |location|
          contact.locations << location
        end
      end
    end
  end
end

