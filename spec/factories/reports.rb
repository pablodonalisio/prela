FactoryBot.define do
  factory :report do
    location_equipment { create(:location_equipment) }
    observations { "Some observation" }
    date { Time.now.beginning_of_day }

    trait :template_based do
      template_based { true }
      report_template { create(:report_template, :with_measurements) }
    end
  end
end
