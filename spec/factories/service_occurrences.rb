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
    end

    trait :suspended do
      status { :suspended }
    end

    trait :scheduled do
      status { :scheduled }
      planned_on_init { 1.week.from_now.change(hour: 9, min: 0, sec: 0) }
      planned_on_finish { planned_on_init.in_time_zone + 1.hour }
    end
  end
end
