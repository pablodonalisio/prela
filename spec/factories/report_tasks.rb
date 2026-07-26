FactoryBot.define do
  factory :report_task do
    report
    sequence(:name) { |n| "Tarea informe #{n}" }
    completed { false }
    position { 0 }
  end
end
