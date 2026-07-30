FactoryBot.define do
  factory :contact do
    name { "Juan Pérez" }
    job_position { "Jefe de planta" }
    work_area { "Operaciones" }
    client { association :client }
    location { nil }
    reports_to { nil }
    distance_above { 0 }
    email { "juan@example.com" }
    phone { "11-1234-5678" }
    description { "Contacto principal" }

    trait :with_superior do
      reports_to { association :contact, client: client }
      distance_above { 1 }
    end
  end
end
