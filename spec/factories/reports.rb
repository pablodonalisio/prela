FactoryBot.define do
  factory :report do
    location_equipment { create(:location_equipment) }
    observations { "Some observation" }
    date { Time.now.beginning_of_day }

    trait :template_based do
      report_template { create(:report_template, :with_measurements) }
      field_values do
        {
          "measurements" => {"1739280000" => "220.5"}
        }
      end
    end
  end
end
