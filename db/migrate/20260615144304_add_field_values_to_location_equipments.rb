class AddFieldValuesToLocationEquipments < ActiveRecord::Migration[8.0]
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
    add_column :location_equipments, :field_values, :jsonb, default: {}, null: false

    MigrationLocationEquipment.find_each do |le|
      equipment = MigrationEquipment.find_by(id: le.equipment_id)
      kind_record = MigrationEquipmentKind.find_by(id: equipment&.equipment_kind_id)
      next unless kind_record&.specific_fields.is_a?(Hash)

      field_values = {}
      kind_record.specific_fields.each do |col_key, definition|
        field_name = definition["name"]
        next if field_name.blank?

        value = le.read_attribute(col_key) if le.has_attribute?(col_key)
        field_values[field_name] = value
      end

      le.update_column(:field_values, field_values)
    end
  end

  def down
    remove_column :location_equipments, :field_values
  end
end
