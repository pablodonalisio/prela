class RemoveLegacyIntervalsAndServiceDatesFromLocationEquipments < ActiveRecord::Migration[8.0]
  INTERVAL_KEYS = %w[
    service_interval
    battery_change_interval
    belt_change_interval
    torque_interval
    cleaning_interval
    srt_900_interval
    thermography_interval
    electrical_approval_interval
  ].freeze

  SERVICE_DATE_COLUMNS = %i[
    last_service
    next_service
    last_battery_change
    next_battery_change
    last_belt_change
    next_belt_change
    last_torque
    next_torque
    last_cleaning
    next_cleaning
    last_srt_900
    next_srt_900
    last_thermography
    next_thermography
    last_electrical_approval
    next_electrical_approval
  ].freeze

  INTERVAL_COLUMNS = %i[
    service_interval
    battery_change_interval
    belt_change_interval
    torque_interval
    cleaning_interval
    srt_900_interval
    thermography_interval
    electrical_approval_interval
  ].freeze

  class MigrationEquipmentKind < ApplicationRecord
    self.table_name = "equipment_kinds"
  end

  class MigrationLocationEquipment < ApplicationRecord
    self.table_name = "location_equipments"
  end

  def up
    strip_interval_keys_from_specific_fields
    strip_interval_keys_from_field_values

    INTERVAL_COLUMNS.each { |column| remove_column :location_equipments, column }
    SERVICE_DATE_COLUMNS.each { |column| remove_column :location_equipments, column }
  end

  def down
    add_column :location_equipments, :service_interval, :integer, default: 1
    add_column :location_equipments, :battery_change_interval, :integer, default: 2
    add_column :location_equipments, :belt_change_interval, :integer, default: 5
    add_column :location_equipments, :torque_interval, :integer, default: 1
    add_column :location_equipments, :cleaning_interval, :integer, default: 1
    add_column :location_equipments, :srt_900_interval, :integer, default: 1
    add_column :location_equipments, :thermography_interval, :integer, default: 1
    add_column :location_equipments, :electrical_approval_interval, :integer, default: 1

    SERVICE_DATE_COLUMNS.each { |column| add_column :location_equipments, column, :date }
  end

  private

  def strip_interval_keys_from_specific_fields
    MigrationEquipmentKind.find_each do |equipment_kind|
      fields = equipment_kind.specific_fields
      next unless fields.is_a?(Hash)

      cleaned = fields.except(*INTERVAL_KEYS)
      next if cleaned == fields

      equipment_kind.update_column(:specific_fields, cleaned)
    end
  end

  def strip_interval_keys_from_field_values
    MigrationLocationEquipment.find_each do |location_equipment|
      values = location_equipment.field_values
      next unless values.is_a?(Hash)
      next unless INTERVAL_KEYS.any? { |key| values.key?(key) }

      location_equipment.update_column(:field_values, values.except(*INTERVAL_KEYS))
    end
  end
end
