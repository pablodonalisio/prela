FactoryBot.define do
  factory :contract do
    client
    name { "Contrato de mantenimiento" }
    starts_on { Date.current }
    ends_on { 1.year.from_now.to_date }
    files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.pdf"), "application/pdf")] }
  end
end
