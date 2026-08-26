FactoryBot.define do
  factory :service_kind do
    sequence(:name) { |n| "Tipo de servicio #{n}" }
    default_interval { 1 }
    interval_unit { :years }
    priority { :normal }

    trait :critical do
      priority { :critical }
    end

    trait :monthly do
      default_interval { 6 }
      interval_unit { :months }
    end

    trait :with_legacy_key do
      sequence(:legacy_key) { |n| "custom_legacy_#{n}" }
    end
  end
end
