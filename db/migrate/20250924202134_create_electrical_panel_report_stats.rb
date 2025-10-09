class CreateElectricalPanelReportStats < ActiveRecord::Migration[8.0]
  def change
    create_table :electrical_panel_report_stats do |t|
      t.string :dimensions
      t.string :mounting_surface
      t.string :physical_state
      t.boolean :voltage_presence_lights_in_operation
      t.string :panel_labeling
      t.string :general_cutoff_switch_model
      t.string :key
      t.string :cabinet_cleaning
      t.string :power_quantity_and_section
      t.string :power_cable_type
      t.string :l1_color
      t.string :l2_color
      t.string :l3_color
      t.string :neutral_color
      t.string :power_rotation_sequency
      t.string :general_cutoff_switch_protection_limit
      t.string :panel_type
      t.boolean :operational_atmospheric_discharger
      t.integer :distributor_or_bars
      t.integer :circuits_without_differentials
      t.integer :circuits_without_thermal_keys
      t.integer :protections_powered_on_garlands
      t.integer :protections_such_as_terminal_blocks
      t.integer :misplaced_switchgears
      t.string :switchgear_type
      t.integer :specialized_switchgears
      t.string :specialized_switchgear_type
      t.integer :conductors_without_terminals
      t.integer :undersized_conductors
      t.integer :conductors_with_marked_aging
      t.integer :conductors_with_clear_colorimetry
      t.integer :conductors_with_splices
      t.integer :overheated_conductors
      t.string :conductors_cable_order
      t.float :average_temperature
      t.boolean :hot_spots_presence
      t.float :l1_amperage
      t.float :l2_amperage
      t.float :l3_amperage
      t.float :neutral_amperage
      t.float :l1_neutral_voltage
      t.float :l2_neutral_voltage
      t.float :l3_neutral_voltage
      t.float :l1_l2_voltage
      t.float :l2_l3_voltage
      t.float :l3_l1_voltage
      t.float :l1_pe_voltage
      t.float :neutral_pe_voltage
      t.boolean :pat_bars_presence
      t.string :ground_cable_status
      t.boolean :pat_cable_continuity_with_circuits
      t.string :pat_cable_section
      t.boolean :cabinet_equipotentialization
      t.boolean :pat_splices_presence
      t.references :report, null: false, foreign_key: true

      t.timestamps
    end
  end
end
