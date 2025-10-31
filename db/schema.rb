# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_30_144126) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "location_equipment_id", null: false
    t.string "description"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind"
    t.index ["location_equipment_id"], name: "index_activities_on_location_equipment_id"
  end

  create_table "batteries", force: :cascade do |t|
    t.string "model"
    t.float "voltage"
    t.float "amps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "description"
    t.string "documentable_type", null: false
    t.bigint "documentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
  end

  create_table "electrical_panel_report_stats", force: :cascade do |t|
    t.string "dimensions"
    t.string "mounting_surface"
    t.string "physical_state"
    t.string "voltage_presence_lights_in_operation"
    t.string "panel_labeling"
    t.string "general_cutoff_switch_model"
    t.string "key"
    t.string "cabinet_cleaning"
    t.string "power_quantity_and_section"
    t.string "power_cable_type"
    t.string "l1_color"
    t.string "l2_color"
    t.string "l3_color"
    t.string "neutral_color"
    t.string "power_rotation_sequency"
    t.string "general_cutoff_switch_protection_limit"
    t.string "panel_type"
    t.string "operational_atmospheric_discharger"
    t.integer "distributor_or_bars"
    t.integer "circuits_without_differentials"
    t.integer "circuits_without_thermal_keys"
    t.integer "protections_powered_on_garlands"
    t.integer "protections_such_as_terminal_blocks"
    t.integer "misplaced_switchgears"
    t.string "switchgear_type"
    t.integer "specialized_switchgears"
    t.string "specialized_switchgear_type"
    t.integer "conductors_without_terminals"
    t.integer "undersized_conductors"
    t.integer "conductors_with_marked_aging"
    t.integer "conductors_with_clear_colorimetry"
    t.integer "conductors_with_splices"
    t.integer "overheated_conductors"
    t.string "conductors_cable_order"
    t.float "average_temperature"
    t.boolean "hot_spots_presence"
    t.float "l1_amperage"
    t.float "l2_amperage"
    t.float "l3_amperage"
    t.float "neutral_amperage"
    t.float "l1_neutral_voltage"
    t.float "l2_neutral_voltage"
    t.float "l3_neutral_voltage"
    t.float "l1_l2_voltage"
    t.float "l2_l3_voltage"
    t.float "l3_l1_voltage"
    t.float "l1_pe_voltage"
    t.float "neutral_pe_voltage"
    t.boolean "pat_bars_presence"
    t.string "ground_cable_status"
    t.boolean "pat_cable_continuity_with_circuits"
    t.string "pat_cable_section"
    t.boolean "cabinet_equipotentialization"
    t.boolean "pat_splices_presence"
    t.bigint "report_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_electrical_panel_report_stats_on_report_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.integer "kind", null: false
    t.string "brand"
    t.string "model", null: false
    t.string "technical_model"
    t.float "kva"
    t.string "manual"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "more_info"
    t.string "motor_brand"
    t.string "motor_model"
    t.string "generator_brand"
    t.string "generator_model"
    t.boolean "is_triphase"
    t.string "size"
  end

  create_table "equipment_supplies", force: :cascade do |t|
    t.string "equipmentable_type", null: false
    t.bigint "equipmentable_id", null: false
    t.string "suppliable_type", null: false
    t.bigint "suppliable_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipmentable_type", "equipmentable_id"], name: "index_equipment_supplies_on_equipmentable"
    t.index ["suppliable_type", "suppliable_id"], name: "index_equipment_supplies_on_suppliable"
  end

  create_table "failures", force: :cascade do |t|
    t.string "description"
    t.date "date"
    t.bigint "location_equipment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_equipment_id"], name: "index_failures_on_location_equipment_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_equipments", force: :cascade do |t|
    t.string "zone"
    t.integer "floor"
    t.bigint "location_id", null: false
    t.bigint "equipment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "serial_number"
    t.date "last_service"
    t.date "next_service"
    t.date "last_battery_change"
    t.date "next_battery_change"
    t.text "details"
    t.string "form_link"
    t.string "code"
    t.integer "status", default: 0
    t.date "last_belt_change"
    t.date "next_belt_change"
    t.string "engine_serial_number"
    t.string "power_unit_serial_number"
    t.integer "service_interval", default: 1
    t.integer "battery_change_interval", default: 2
    t.integer "belt_change_interval", default: 5
    t.integer "torque_interval", default: 1
    t.date "last_torque"
    t.date "next_torque"
    t.integer "cleaning_interval", default: 1
    t.date "last_cleaning"
    t.date "next_cleaning"
    t.integer "srt_900_interval", default: 1
    t.date "last_srt_900"
    t.date "next_srt_900"
    t.integer "thermography_interval", default: 1
    t.date "last_thermography"
    t.date "next_thermography"
    t.integer "electrical_approval_interval", default: 1
    t.date "last_electrical_approval"
    t.date "next_electrical_approval"
    t.string "condition", default: "Buena"
    t.index ["equipment_id"], name: "index_location_equipments_on_equipment_id"
    t.index ["location_id"], name: "index_location_equipments_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_locations_on_client_id"
  end

  create_table "power_unit_report_stats", force: :cascade do |t|
    t.bigint "report_id", null: false
    t.string "general_disconnector"
    t.string "emergency_stop_position"
    t.string "start_key_on_auto"
    t.integer "rpm"
    t.float "frequency"
    t.float "battery_charge_control"
    t.integer "tension_between_phases_a_b"
    t.integer "tension_between_phases_b_c"
    t.integer "tension_between_phases_c_a"
    t.float "initial_temperature"
    t.float "running_temperature"
    t.integer "number_of_starts"
    t.float "operating_time"
    t.integer "failed_starts"
    t.float "oil_pressure"
    t.string "fuel_level"
    t.string "coolant_level"
    t.string "oil_level"
    t.integer "testing_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lamp_test"
    t.string "belt_condition"
    t.string "air_filter_condition"
    t.string "anti_vibration_pad_condition"
    t.string "liquids_leaks"
    t.string "connections_condition_and_battery_fixation"
    t.string "cable_and_electrical_connections"
    t.string "oil_pressure_unit"
    t.index ["report_id"], name: "index_power_unit_report_stats_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "location_equipment_id", null: false
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.index ["location_equipment_id"], name: "index_reports_on_location_equipment_id"
  end

  create_table "room_report_stats", force: :cascade do |t|
    t.bigint "report_id", null: false
    t.string "room_status"
    t.string "air_conditioning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "temperature"
    t.float "humidity"
    t.string "clean_and_tidy"
    t.string "ventilated"
    t.string "free_access_to_panel"
    t.string "with_access_key"
    t.index ["report_id"], name: "index_room_report_stats_on_report_id"
  end

  create_table "service_dates", force: :cascade do |t|
    t.integer "kind"
    t.datetime "date"
    t.bigint "location_equipment_id", null: false
    t.bigint "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_service_dates_on_activity_id"
    t.index ["location_equipment_id"], name: "index_service_dates_on_location_equipment_id"
  end

  create_table "ups_report_stats", force: :cascade do |t|
    t.bigint "report_id", null: false
    t.string "operating_mode"
    t.float "associated_charge"
    t.float "battery_charge"
    t.float "voltage_input"
    t.float "voltage_output"
    t.string "pat_state"
    t.string "alarms_presence"
    t.string "ventilation_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "voltage_input_l1"
    t.float "voltage_input_l2"
    t.float "voltage_input_l3"
    t.float "voltage_output_l1"
    t.float "voltage_output_l2"
    t.float "voltage_output_l3"
    t.index ["report_id"], name: "index_ups_report_stats_on_report_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.bigint "client_id"
    t.boolean "editor"
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "location_equipments"
  add_foreign_key "electrical_panel_report_stats", "reports"
  add_foreign_key "failures", "location_equipments"
  add_foreign_key "location_equipments", "equipment"
  add_foreign_key "location_equipments", "locations"
  add_foreign_key "locations", "clients"
  add_foreign_key "power_unit_report_stats", "reports"
  add_foreign_key "reports", "location_equipments"
  add_foreign_key "room_report_stats", "reports"
  add_foreign_key "service_dates", "activities"
  add_foreign_key "service_dates", "location_equipments"
  add_foreign_key "ups_report_stats", "reports"
  add_foreign_key "users", "clients"
end
