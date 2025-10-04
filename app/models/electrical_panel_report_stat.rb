class ElectricalPanelReportStat < ApplicationRecord
  MOUNTING_SURFACE_OPTIONS = ["Empotrado", "Sobre mampostería", "Durlock", "Poste"]
  PHYSICAL_STATE_OPTIONS = ["Perfecto", "Deficiente", "Malo"]
  PANEL_LABELING_OPTIONS = ["Perfecto", "Deficiente", "Malo", "Inexistente"]
  KEY_OPTIONS = ["Sin llave", "Con llave", "Con combinación"]
  CABINET_CLEANING_OPTIONS = ["Perfecto", "Deficiente", "Malo"]
  POWER_CABLE_TYPE_OPTIONS = ["Subterráneo", "TPR", "Unipolares"]
  POWER_ROTATION_SEQUENCY_OPTIONS = ["Horario", "Antihorario"]
  PANEL_TYPE_OPTIONS = ["Seccional", "Principal", "Distribuidor de cargas", "Coseno phi", "Tablero de aislación"]
  CONDUCTORS_CABLE_ORDER_OPTIONS = ["Perfecto", "Bueno", "Deficiente", "Malo"]
  GROUND_CABLE_STATUS_OPTIONS = ["Perfecto", "Deficiente", "Malo"]
  belongs_to :report

  validates :dimensions, :mounting_surface, :physical_state,
    :panel_labeling, :general_cutoff_switch_model, :key, :cabinet_cleaning,
    :power_quantity_and_section, :power_cable_type, :l1_color,
    :neutral_color, :power_rotation_sequency, :general_cutoff_switch_protection_limit,
    :panel_type, :distributor_or_bars,
    :circuits_without_differentials, :circuits_without_thermal_keys,
    :protections_powered_on_garlands, :protections_such_as_terminal_blocks,
    :misplaced_switchgears, :switchgear_type, :specialized_switchgears,
    :specialized_switchgear_type, :conductors_without_terminals, :undersized_conductors,
    :conductors_with_marked_aging, :conductors_with_clear_colorimetry, :conductors_with_splices,
    :overheated_conductors, :conductors_cable_order, :average_temperature,
    :l1_amperage, :neutral_amperage, :l1_neutral_voltage, :neutral_pe_voltage,
    :ground_cable_status, :pat_cable_section, presence: true

  validates :l2_color, :l3_color, :l2_amperage, :l3_amperage, :l2_neutral_voltage, :l3_neutral_voltage,
    :l1_l2_voltage, :l2_l3_voltage, :l3_l1_voltage, presence: true, if: :is_triphase?
  validates :l1_pe_voltage, presence: true, if: :is_monophase?

  validates :voltage_presence_lights_in_operation, inclusion: {in: [true, false]}
  validates :operational_atmospheric_discharger, inclusion: {in: [true, false]}
  validates :hot_spots_presence, inclusion: {in: [true, false]}
  validates :pat_bars_presence, inclusion: {in: [true, false]}
  validates :pat_cable_continuity_with_circuits, inclusion: {in: [true, false]}
  validates :cabinet_equipotentialization, inclusion: {in: [true, false]}
  validates :pat_splices_presence, inclusion: {in: [true, false]}

  def is_triphase?
    report.location_equipment.equipment.is_triphase
  end

  def is_monophase?
    !is_triphase?
  end

  def self.permitted_attributes
    %i[dimensions
      mounting_surface
      physical_state
      voltage_presence_lights_in_operation
      panel_labeling
      general_cutoff_switch_model
      key
      cabinet_cleaning
      power_quantity_and_section
      power_cable_type
      l1_color
      l2_color
      l3_color
      neutral_color
      power_rotation_sequency
      general_cutoff_switch_protection_limit
      panel_type
      operational_atmospheric_discharger
      distributor_or_bars
      circuits_without_differentials
      circuits_without_thermal_keys
      protections_powered_on_garlands
      protections_such_as_terminal_blocks
      misplaced_switchgears
      switchgear_type
      specialized_switchgears
      specialized_switchgear_type
      conductors_without_terminals
      undersized_conductors
      conductors_with_marked_aging
      conductors_with_clear_colorimetry
      conductors_with_splices
      overheated_conductors
      conductors_cable_order
      average_temperature
      hot_spots_presence
      l1_amperage
      l2_amperage
      l3_amperage
      neutral_amperage
      l1_neutral_voltage
      l2_neutral_voltage
      l3_neutral_voltage
      l1_l2_voltage
      l2_l3_voltage
      l3_l1_voltage
      l1_pe_voltage
      neutral_pe_voltage
      pat_bars_presence
      ground_cable_status
      pat_cable_continuity_with_circuits
      pat_cable_section
      cabinet_equipotentialization
      pat_splices_presence]
  end
end
