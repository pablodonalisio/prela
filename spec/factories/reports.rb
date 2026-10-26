FactoryBot.define do
  factory :report do
    location_equipment { create(:location_equipment) }
    observations { "Some observation" }
    date { Time.now.beginning_of_day }

    trait :uploaded do
      uploaded { true }

      after(:build) do |report|
        next if report.files.attached?

        report.files.attach(
          io: StringIO.new(File.binread(Rails.root.join("spec/fixtures/files/test.pdf"))),
          filename: "test.pdf",
          content_type: "application/pdf"
        )
      end
    end

    trait :template_based do
      template_based { true }
      report_template { create(:report_template, :with_measurements) }
    end
  end
end
