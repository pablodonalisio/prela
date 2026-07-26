class AddFieldValuesToEquipment < ActiveRecord::Migration[8.0]
  class MigrationEquipmentKind < ApplicationRecord
    self.table_name = "equipment_kinds"
  end

  class MigrationEquipment < ApplicationRecord
    self.table_name = "equipment"
  end

  def up
    add_column :equipment, :field_values, :jsonb, default: {}, null: false

    MigrationEquipment.find_each do |equipment|
      kind_record = MigrationEquipmentKind.find_by(id: equipment.equipment_kind_id)
      next unless kind_record&.generic_fields.is_a?(Hash)

      field_values = {}
      kind_record.generic_fields.each do |col_key, definition|
        field_name = definition["name"]
        next if field_name.blank?

        value = equipment.read_attribute(col_key) if equipment.has_attribute?(col_key)
        field_values[field_name] = value
      end

      equipment.update_column(:field_values, field_values)
    end
  end

  def down
    remove_column :equipment, :field_values
  end
end
