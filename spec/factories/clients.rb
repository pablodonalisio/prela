FactoryBot.define do
  factory :client do
    name { "MyString" }

    trait :without_subscription do
      has_subscription { false }
    end
  end
end
