class AddGenericSpecificFieldsAndLegacyKindToEquipmentKinds < ActiveRecord::Migration[8.0]
  class MigrationEquipmentKind < ApplicationRecord
    self.table_name = "equipment_kinds"
  end

  class MigrationEquipment < ApplicationRecord
    self.table_name = "equipment"

    enum :kind, {ups: 0, power_unit: 1, electrical_panel: 2, building: 3}
  end

  SEEDS = {
    "ups" => {
      name: "UPS",
      generic_fields: {
        "brand" => {"name" => "Marca", "type" => "string"},
        "model" => {"name" => "Modelo", "type" => "string"},
        "is_triphase" => {"name" => "Trifásica", "type" => "boolean"},
        "technical_model" => {"name" => "Modelo Técnico", "type" => "string"},
        "kva" => {"name" => "Kva", "type" => "float"},
        "more_info" => {"name" => "Mas Info", "type" => "string"},
        "manual" => {"name" => "Manual", "type" => "string"}
      },
      specific_fields: {
        "serial_number" => {"name" => "Número de serie", "type" => "string"},
        "code" => {"name" => "Código", "type" => "string"},
        "battery_change_interval" => {"name" => "Intervalo cambio batería (años)", "type" => "integer"},
        "form_link" => {"name" => "Link Formulario", "type" => "string"}
      }
    },
    "power_unit" => {
      name: "Grupo Electrógeno",
      generic_fields: {
        "brand" => {"name" => "Marca", "type" => "string"},
        "model" => {"name" => "Modelo", "type" => "string"},
        "motor_brand" => {"name" => "Marca del Motor", "type" => "string"},
        "motor_model" => {"name" => "Modelo del Motor", "type" => "string"},
        "generator_brand" => {"name" => "Marca del Generador", "type" => "string"},
        "generator_model" => {"name" => "Modelo del Generador", "type" => "string"},
        "kva" => {"name" => "Kva", "type" => "float"},
        "more_info" => {"name" => "Mas Info", "type" => "string"},
        "manual" => {"name" => "Manual", "type" => "string"}
      },
      specific_fields: {
        "serial_number" => {"name" => "Número de serie del generador", "type" => "string"},
        "engine_serial_number" => {"name" => "Número de serie del motor", "type" => "string"},
        "power_unit_serial_number" => {"name" => "Número de serie del grupo electrógeno", "type" => "string"},
        "code" => {"name" => "Código", "type" => "string"},
        "service_interval" => {"name" => "Intervalo entre servicios (años)", "type" => "integer"},
        "battery_change_interval" => {"name" => "Intervalo de cambio de batería (años)", "type" => "integer"},
        "belt_change_interval" => {"name" => "Intervalo de cambio de correa (años)", "type" => "integer"},
        "form_link" => {"name" => "Link Formulario", "type" => "string"}
      }
    },
    "electrical_panel" => {
      name: "Tablero Eléctrico",
      generic_fields: {
        "model" => {"name" => "Nombre", "type" => "string"},
        "is_triphase" => {"name" => "Trifásica", "type" => "boolean"},
        "size" => {"name" => "Tamaño", "type" => "string"},
        "more_info" => {"name" => "Mas Info", "type" => "string"}
      },
      specific_fields: {
        "code" => {"name" => "Código", "type" => "string"},
        "service_interval" => {"name" => "Intervalo entre servicios (años)", "type" => "integer"},
        "torque_interval" => {"name" => "Intervalo de torqueo (años)", "type" => "integer"},
        "cleaning_interval" => {"name" => "Intervalo de limpieza (años)", "type" => "integer"}
      }
    },
    "building" => {
      name: "Edificio",
      generic_fields: {
        "model" => {"name" => "Nombre", "type" => "string"},
        "more_info" => {"name" => "Mas Info", "type" => "string"}
      },
      specific_fields: {
        "srt_900_interval" => {"name" => "Intervalo medición SRT 900 (años)", "type" => "integer"},
        "thermography_interval" => {"name" => "Intervalo de termografía (años)", "type" => "integer"},
        "electrical_approval_interval" => {"name" => "Intervalo de apto eléctrica (años)", "type" => "integer"}
      }
    }
  }.freeze

  def up
    rename_column :equipment_kinds, :fields, :generic_fields
    add_column :equipment_kinds, :specific_fields, :jsonb, null: false, default: {}
    add_column :equipment_kinds, :legacy_kind, :string
    add_column :equipment_kinds, :description, :text
    add_column :equipment_kinds, :normalized_name, :string
    add_index :equipment_kinds, :legacy_kind, unique: true, where: "legacy_kind IS NOT NULL"

    seed_equipment_kinds
    backfill_normalized_names
    add_index :equipment_kinds, :normalized_name, unique: true
    backfill_equipment_kind_ids
  end

  def down
    MigrationEquipment.where.not(equipment_kind_id: nil).update_all(equipment_kind_id: nil)

    MigrationEquipmentKind.where.not(legacy_kind: nil).delete_all

    remove_index :equipment_kinds, :normalized_name
    remove_index :equipment_kinds, :legacy_kind
    remove_column :equipment_kinds, :normalized_name
    remove_column :equipment_kinds, :description
    remove_column :equipment_kinds, :legacy_kind
    remove_column :equipment_kinds, :specific_fields
    rename_column :equipment_kinds, :generic_fields, :fields
  end

  private

  def seed_equipment_kinds
    SEEDS.each do |legacy_kind, attributes|
      kind = MigrationEquipmentKind.find_or_initialize_by(legacy_kind: legacy_kind)
      kind.assign_attributes(attributes)
      kind.save!
    end
  end

  def backfill_equipment_kind_ids
    MigrationEquipment.kinds.each_key do |kind|
      equipment_kind = MigrationEquipmentKind.find_by!(legacy_kind: kind)
      MigrationEquipment.where(kind: kind, equipment_kind_id: nil)
        .update_all(equipment_kind_id: equipment_kind.id)
    end
  end

  def backfill_normalized_names
    MigrationEquipmentKind.find_each do |equipment_kind|
      equipment_kind.update_column(:normalized_name, normalize_name(equipment_kind.name))
    end
  end

  def normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end
end
