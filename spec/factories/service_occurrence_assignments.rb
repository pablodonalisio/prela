FactoryBot.define do
  factory :service_occurrence_assignment do
    service_occurrence
    association :user, factory: :technician
  end
end
