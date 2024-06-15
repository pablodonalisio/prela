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

ActiveRecord::Schema[7.1].define(version: 2024_06_11_213522) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "equipment_power"
    t.boolean "general_disconnector"
    t.boolean "emergency_stop_position"
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
    t.integer "operating_time"
    t.integer "failed_starts"
    t.float "oil_pressure"
    t.integer "fuel_level"
    t.integer "coolant_level"
    t.integer "oil_level"
    t.integer "testing_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["report_id"], name: "index_room_report_stats_on_report_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "location_equipments", "equipment"
  add_foreign_key "location_equipments", "locations"
  add_foreign_key "locations", "clients"
  add_foreign_key "power_unit_report_stats", "reports"
  add_foreign_key "reports", "location_equipments"
  add_foreign_key "room_report_stats", "reports"
  add_foreign_key "ups_report_stats", "reports"
end
