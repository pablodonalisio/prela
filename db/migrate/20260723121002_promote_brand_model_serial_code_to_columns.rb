class PromoteBrandModelSerialCodeToColumns < ActiveRecord::Migration[7.1]
  GENERIC_KEYS = %w[brand model].freeze
  SPECIFIC_KEYS = %w[serial_number code].freeze

  def up
    backfill_equipment_columns
    backfill_location_equipment_columns
    strip_equipment_kind_definitions
    strip_equipment_field_values
    strip_location_equipment_field_values
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def backfill_equipment_columns
    say_with_time "Backfilling equipment.brand/model from field_values" do
      execute <<~SQL.squish
        UPDATE equipment
        SET
          brand = COALESCE(NULLIF(brand, ''), field_values->>'brand'),
          model = COALESCE(NULLIF(model, ''), field_values->>'model')
        WHERE field_values ?| ARRAY['brand', 'model']
      SQL
    end
  end

  def backfill_location_equipment_columns
    say_with_time "Backfilling location_equipments.serial_number/code from field_values" do
      execute <<~SQL.squish
        UPDATE location_equipments
        SET
          serial_number = COALESCE(NULLIF(serial_number, ''), field_values->>'serial_number'),
          code = COALESCE(NULLIF(code, ''), field_values->>'code')
        WHERE field_values ?| ARRAY['serial_number', 'code']
      SQL
    end
  end

  def strip_equipment_kind_definitions
    say_with_time "Removing brand/model/serial_number/code from equipment_kinds field definitions" do
      EquipmentKind.find_each do |kind|
        generic = kind.generic_fields.except(*GENERIC_KEYS)
        specific = kind.specific_fields.except(*SPECIFIC_KEYS)
        next if generic == kind.generic_fields && specific == kind.specific_fields

        kind.update_columns(generic_fields: generic, specific_fields: specific)
      end
    end
  end

  def strip_equipment_field_values
    say_with_time "Removing brand/model keys from equipment.field_values" do
      Equipment.find_each do |equipment|
        values = equipment.field_values.except(*GENERIC_KEYS)
        next if values == equipment.field_values

        equipment.update_columns(field_values: values)
      end
    end
  end

  def strip_location_equipment_field_values
    say_with_time "Removing serial_number/code keys from location_equipments.field_values" do
      LocationEquipment.find_each do |location_equipment|
        values = location_equipment.field_values.except(*SPECIFIC_KEYS)
        next if values == location_equipment.field_values

        location_equipment.update_columns(field_values: values)
      end
    end
  end
end
