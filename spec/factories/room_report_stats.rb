FactoryBot.define do
  factory :room_report_stat do
    report { create(:report) }
    room_status { "Correcto" }
    air_conditioning { "Falta refrigeración" }
    temperature { 25.5 }
    humidity { 50.5 }
  end
end
