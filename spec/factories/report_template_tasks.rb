FactoryBot.define do
  factory :report_template_task do
    report_template
    sequence(:name) { |n| "Tarea plantilla #{n}" }
    position { 0 }
  end
end
