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

ActiveRecord::Schema[7.1].define(version: 2023_12_12_123809) do
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
    t.string "kind", null: false
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
end
