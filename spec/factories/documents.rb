FactoryBot.define do
  factory :document do
    description { "Unifilar" }
    documentable { create(:location_equipment) }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf") }
  end
end
