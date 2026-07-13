FactoryBot.define do
  factory :report_comment do
    report
    sequence(:description) { |n| "Comentario #{n}" }
    position { 0 }
  end
end
