FactoryBot.define do
  factory :power_unit_report_stat do
    report
    general_disconnector { "ON" }
    emergency_stop_position { "OFF" }
    start_key_on_auto { "ON" }
    rpm { 1500 }
    frequency { 50.0 }
    battery_charge_control { 26.0 }
    tension_between_phases_a_b { 380 }
    tension_between_phases_b_c { 380 }
    tension_between_phases_c_a { 380 }
    initial_temperature { 20 }
    running_temperature { 40 }
    number_of_starts { 1 }
    operating_time { 1 }
    failed_starts { 0 }
    oil_pressure { 4.0 }
    oil_pressure_unit { "bar" }
    fuel_level { 75 }
    coolant_level { "Bajo" }
    oil_level { "Medio" }
    testing_time { 10 }
  end
end
