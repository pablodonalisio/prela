FactoryBot.define do
  factory :room_report_stat do
    report { create(:report) }
    room_status { "Elementos ajenos a la sala" }
    air_conditioning { "Falta refrigeración" }
  end
end
