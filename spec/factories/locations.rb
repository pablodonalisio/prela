FactoryBot.define do
  factory :location do
    name { "MyString" }
    client { create :client }
  end
end
