FactoryBot.define do
  factory :client do
    name { "MyString" }
    avatar { Rack::Test::UploadedFile.new(Rails.root.join("app", "assets", "images", "placeholder-img.jpeg"), "image/jpeg") }
  end
end
