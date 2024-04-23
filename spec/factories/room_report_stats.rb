FactoryBot.define do
  factory :room_report_stat do
    report { create(:report) }
    room_status { "Correcto" }
    air_conditioning { "Falta refrigeración" }
  end
end
