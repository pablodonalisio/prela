FactoryBot.define do
  factory :user do
    email { "test#{rand(10000)}@email.com" }
    password { "password" }
  end
end
