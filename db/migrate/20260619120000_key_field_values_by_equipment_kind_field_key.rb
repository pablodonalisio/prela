class KeyFieldValuesByEquipmentKindFieldKey < ActiveRecord::Migration[8.0]
  class MigrationEquipmentKind < ApplicationRecord
    self.table_name = "equipment_kinds"
  end

  class MigrationEquipment < ApplicationRecord
    self.table_name = "equipment"
  end

  class MigrationLocationEquipment < ApplicationRecord
    self.table_name = "location_equipments"
  end

  def up
    reset_migration_model_caches

    MigrationEquipment.find_each do |equipment|
      kind = MigrationEquipmentKind.find_by(id: equipment.equipment_kind_id)
      next unless kind&.generic_fields.is_a?(Hash)

      remapped = remap_field_values(equipment.field_values, kind.generic_fields)
      equipment.update_column(:field_values, remapped) if remapped != equipment.field_values
    end

    MigrationLocationEquipment.find_each do |location_equipment|
      equipment = MigrationEquipment.find_by(id: location_equipment.equipment_id)
      kind = MigrationEquipmentKind.find_by(id: equipment&.equipment_kind_id)
      next unless kind&.specific_fields.is_a?(Hash)

      remapped = remap_field_values(location_equipment.field_values, kind.specific_fields)
      location_equipment.update_column(:field_values, remapped) if remapped != location_equipment.field_values
    end
  end

  def down
    reset_migration_model_caches

    MigrationEquipment.find_each do |equipment|
      kind = MigrationEquipmentKind.find_by(id: equipment.equipment_kind_id)
      next unless kind&.generic_fields.is_a?(Hash)

      remapped = unmap_field_values(equipment.field_values, kind.generic_fields)
      equipment.update_column(:field_values, remapped) if remapped != equipment.field_values
    end

    MigrationLocationEquipment.find_each do |location_equipment|
      equipment = MigrationEquipment.find_by(id: location_equipment.equipment_id)
      kind = MigrationEquipmentKind.find_by(id: equipment&.equipment_kind_id)
      next unless kind&.specific_fields.is_a?(Hash)

      remapped = unmap_field_values(location_equipment.field_values, kind.specific_fields)
      location_equipment.update_column(:field_values, remapped) if remapped != location_equipment.field_values
    end
  end

  private

  # Previous migrations in the same db:prepare process alter equipment columns
  # (e.g. remove kind). Clear AR/PG prepared statement caches before querying.
  def reset_migration_model_caches
    [MigrationEquipment, MigrationLocationEquipment, MigrationEquipmentKind].each(&:reset_column_information)
    ActiveRecord::Base.connection.clear_cache!
  end

  def remap_field_values(field_values, definitions)
    field_values = field_values.presence || {}
    name_to_key = definitions.each_with_object({}) do |(key, definition), mapping|
      mapping[definition["name"]] = key if definition["name"].present?
    end

    field_values.each_with_object({}) do |(key_or_name, value), remapped|
      if definitions.key?(key_or_name)
        remapped[key_or_name] = value
      elsif (field_key = name_to_key[key_or_name])
        remapped[field_key] = value
      end
    end
  end

  def unmap_field_values(field_values, definitions)
    field_values = field_values.presence || {}

    field_values.each_with_object({}) do |(field_key, value), remapped|
      field_name = definitions.dig(field_key, "name")
      remapped[field_name || field_key] = value
    end
  end
end
