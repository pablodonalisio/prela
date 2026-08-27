FactoryBot.define do
  factory :service_kind do
    sequence(:name) { |n| "Tipo de servicio #{n}" }
    default_interval { 1 }
    interval_unit { :years }
    priority { :normal }
    recurring { true }

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

    trait :one_time do
      recurring { false }
      default_interval { nil }
      interval_unit { nil }
    end
  end
end
