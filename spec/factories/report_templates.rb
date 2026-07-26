FactoryBot.define do
  factory :report_template do
    sequence(:name) { |n| "Plantilla de informe #{n}" }

    trait :with_measurements do
      measurements do
        {"1739280000" => {name: "Tensión L1", type: "float", optimal_value: "220", units: "V"}}
      end
    end

    trait :with_tasks do
      after(:create) do |template|
        ReportTemplateTask.create!(report_template_id: template.id, name: "Limpieza general", position: 0)
        ReportTemplateTask.create!(report_template_id: template.id, name: "Verificación de torque", position: 1)
        template.report_template_tasks.reset
      end
    end
  end
end
