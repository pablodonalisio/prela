FactoryBot.define do
  factory :electrical_panel_report_stat do
    dimensions { "X x Y x Z" }
    mounting_surface { "Empotrado" }
    physical_state { "Perfecto" }
    voltage_presence_lights_in_operation { "No posee" }
    panel_labeling { "Deficiente" }
    general_cutoff_switch_model { "Interruptor General" }
    key { "Sin llave" }
    cabinet_cleaning { "Malo" }
    power_quantity_and_section { "4 x 10 mm2" }
    power_cable_type { "Subterráneo" }
    l1_color { "Rojo" }
    l2_color { "Amarillo" }
    l3_color { "Azul" }
    neutral_color { "Blanco" }
    power_rotation_sequency { "Horaria" }
    general_cutoff_switch_protection_limit { "C4 x 16A" }
    panel_type { "Seccional" }
    operational_atmospheric_discharger { false }
    distributor_or_bars { 1 }
    circuits_without_differentials { 1 }
    circuits_without_thermal_keys { 1 }
    protections_powered_on_garlands { 1 }
    protections_such_as_terminal_blocks { 1 }
    misplaced_switchgears { 1 }
    switchgear_type { "Tipo de aparamenta" }
    specialized_switchgears { 1 }
    specialized_switchgear_type { "Tipo de aparamenta especializada" }
    conductors_without_terminals { 1 }
    undersized_conductors { 1 }
    conductors_with_marked_aging { 1 }
    conductors_with_clear_colorimetry { 1 }
    conductors_with_splices { 1 }
    overheated_conductors { 1 }
    conductors_cable_order { "Bueno" }
    average_temperature { 1.5 }
    hot_spots_presence { false }
    l1_amperage { 1.5 }
    l2_amperage { 1.5 }
    l3_amperage { 1.5 }
    neutral_amperage { 1.5 }
    l1_neutral_voltage { 1.5 }
    l2_neutral_voltage { 1.5 }
    l3_neutral_voltage { 1.5 }
    l1_l2_voltage { 1.5 }
    l2_l3_voltage { 1.5 }
    l3_l1_voltage { 1.5 }
    l1_pe_voltage { 1.5 }
    neutral_pe_voltage { 1.5 }
    torque_date { "2025-09-24" }
    pat_bars_presence { false }
    ground_cable_status { "Perfecto" }
    pat_cable_continuity_with_circuits { false }
    pat_cable_section { "1 x 6mm2" }
    cabinet_equipotentialization { false }
    pat_splices_presence { false }
  end
end
