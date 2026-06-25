FactoryBot.define do
  factory :report_template do
    sequence(:name) { |n| "Plantilla de informe #{n}" }

    trait :with_measurements do
      measurements do
        {"1739280000" => {name: "Tensión L1", type: "float"}}
      end
    end
  end
end
