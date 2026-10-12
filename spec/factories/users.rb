FactoryBot.define do
  factory :user do
    email { "test#{rand(10000)}@email.com" }
    password { "password" }
    editor { false }
  end

  factory :admin, parent: :user do
    role { "admin" }
    editor { true }
  end

  factory :technician, parent: :user do
    role { "technician" }
  end
end
