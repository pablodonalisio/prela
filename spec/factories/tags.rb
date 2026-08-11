FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Etiqueta #{n}" }
    color { Tag::DEFAULT_COLOR }
  end
end
