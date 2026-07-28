FactoryBot.define do
  factory :contact do
    name { "Juan Pérez" }
    job_position { "Jefe de planta" }
    work_area { "Operaciones" }
    client { association :client }
    location { nil }
    reports_to { nil }
    email { "juan@example.com" }
    phone { "11-1234-5678" }
    description { "Contacto principal" }
  end
end
