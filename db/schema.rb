# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_08_090142) do

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "alarms", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.integer "alarm_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.integer "value", null: false
    t.integer "threshold", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_alarms_on_device_id"
  end

  create_table "background_tasks", force: :cascade do |t|
    t.integer "task_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "outcome", default: 0, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.json "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outcome"], name: "index_background_tasks_on_outcome"
    t.index ["status"], name: "index_background_tasks_on_status"
    t.index ["task_type"], name: "index_background_tasks_on_task_type"
  end

  create_table "device_data_records", force: :cascade do |t|
    t.string "device_id", null: false
    t.integer "footfall"
    t.integer "battery"
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
  end

  create_table "device_groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_device_groups_on_name", unique: true
  end

  create_table "devices", force: :cascade do |t|
    t.string "device_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "footfall_threshold_amber", null: false
    t.integer "footfall_threshold_red", null: false
    t.integer "battery_threshold_amber", null: false
    t.integer "battery_threshold_red", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "device_group_id"
    t.integer "footfall"
    t.integer "battery"
    t.integer "device_type", default: 0, null: false
    t.index ["device_group_id"], name: "index_devices_on_device_group_id"
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.integer "default_footfall_threshold_amber", null: false
    t.integer "default_footfall_threshold_red", null: false
    t.integer "default_battery_threshold_amber", null: false
    t.integer "default_battery_threshold_red", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "default_latitude", precision: 10, scale: 6, default: "54.607577", null: false
    t.decimal "default_longitude", precision: 10, scale: 6, default: "-6.693145", null: false
    t.integer "default_zoom_no_location", default: 8, null: false
    t.integer "default_zoom_specific_location", default: 12, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.json "object"
    t.datetime "created_at"
    t.json "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "devices", "device_groups"
end
