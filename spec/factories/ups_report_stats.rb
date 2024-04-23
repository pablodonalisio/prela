FactoryBot.define do
  factory :ups_report_stat do
    report { create(:report) }
    operating_mode { "Normal" }
    associated_charge { 10 }
    battery_charge { 100 }
    voltage_input { 230 }
    voltage_output { 225 }
    pat_state { "Correcto" }
    alarms_presence { "Si" }
    ventilation_state { "Bien" }
  end
end
