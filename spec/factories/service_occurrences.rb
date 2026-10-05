FactoryBot.define do
  factory :service_occurrence do
    location_equipment_service
    due_on { 1.month.from_now.to_date }
    status { :pending }

    trait :overdue do
      due_on { 1.month.ago.to_date }
    end

    trait :due_soon do
      due_on { 1.month.from_now.to_date }
    end

    trait :completed do
      status { :completed }
      completed_on { Date.current }
      start_time { "09:00" }
      end_time { "11:00" }
    end

    trait :suspended do
      status { :suspended }
    end

    trait :scheduled do
      status { :scheduled }
      planned_on { 1.week.from_now.to_date }
      start_time { "09:00" }
      end_time { "11:00" }
    end
  end
end
