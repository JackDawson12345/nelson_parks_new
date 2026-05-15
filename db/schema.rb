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

ActiveRecord::Schema[7.2].define(version: 2026_05_13_150011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invoice_batches", force: :cascade do |t|
    t.bigint "park_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.date "invoice_date"
    t.date "due_date"
    t.text "notes"
    t.json "reading"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utility"
    t.string "reference"
    t.string "status"
    t.index ["park_id"], name: "index_invoice_batches_on_park_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pitch_id", null: false
    t.string "invoice_id"
    t.string "status"
    t.decimal "total"
    t.decimal "amount_due"
    t.decimal "amount_paid"
    t.datetime "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["pitch_id"], name: "index_invoices_on_pitch_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "late_payments", force: :cascade do |t|
    t.bigint "pitch_id", null: false
    t.bigint "park_id", null: false
    t.bigint "user_id", null: false
    t.decimal "vat"
    t.decimal "net_total"
    t.decimal "vat_total"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "due_date"
    t.index ["park_id"], name: "index_late_payments_on_park_id"
    t.index ["pitch_id"], name: "index_late_payments_on_pitch_id"
    t.index ["user_id"], name: "index_late_payments_on_user_id"
  end

  create_table "lodge_payments", force: :cascade do |t|
    t.bigint "pitch_id", null: false
    t.bigint "park_id", null: false
    t.bigint "user_id", null: false
    t.integer "year"
    t.string "frequency"
    t.decimal "vat"
    t.decimal "net_total"
    t.decimal "vat_total"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["park_id"], name: "index_lodge_payments_on_park_id"
    t.index ["pitch_id"], name: "index_lodge_payments_on_pitch_id"
    t.index ["user_id"], name: "index_lodge_payments_on_user_id"
  end

  create_table "meter_readings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pitch_id", null: false
    t.string "utility"
    t.decimal "opening_reading"
    t.decimal "closing_reading"
    t.decimal "consumption"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
    t.index ["pitch_id"], name: "index_meter_readings_on_pitch_id"
    t.index ["user_id"], name: "index_meter_readings_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "seen", default: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "parks", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pitch_fees", force: :cascade do |t|
    t.bigint "pitch_id", null: false
    t.bigint "park_id", null: false
    t.bigint "user_id", null: false
    t.integer "year"
    t.string "frequency"
    t.decimal "vat", precision: 10, scale: 2
    t.decimal "net_total", precision: 10, scale: 2
    t.decimal "vat_total", precision: 10, scale: 2
    t.decimal "total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["park_id"], name: "index_pitch_fees_on_park_id"
    t.index ["pitch_id"], name: "index_pitch_fees_on_pitch_id"
    t.index ["user_id"], name: "index_pitch_fees_on_user_id"
  end

  create_table "pitches", force: :cascade do |t|
    t.string "pitch_number"
    t.bigint "park_id", null: false
    t.string "pitch_type"
    t.string "status"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["park_id"], name: "index_pitches_on_park_id"
    t.index ["user_id"], name: "index_pitches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.text "full_name"
    t.text "phone_number"
    t.string "xero_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "utilities", force: :cascade do |t|
    t.bigint "pitch_id", null: false
    t.bigint "park_id", null: false
    t.bigint "user_id", null: false
    t.integer "year"
    t.string "frequency"
    t.decimal "vat"
    t.decimal "net_total"
    t.decimal "vat_total"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["park_id"], name: "index_utilities_on_park_id"
    t.index ["pitch_id"], name: "index_utilities_on_pitch_id"
    t.index ["user_id"], name: "index_utilities_on_user_id"
  end

  create_table "utility_rates", force: :cascade do |t|
    t.bigint "park_id", null: false
    t.string "utility"
    t.decimal "unit_rate", precision: 10, scale: 4
    t.decimal "standing_rate", precision: 10, scale: 4
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "from_date"
    t.date "to_date"
    t.index ["park_id"], name: "index_utility_rates_on_park_id"
  end

  add_foreign_key "invoice_batches", "parks"
  add_foreign_key "invoices", "pitches"
  add_foreign_key "invoices", "users"
  add_foreign_key "late_payments", "parks"
  add_foreign_key "late_payments", "pitches"
  add_foreign_key "late_payments", "users"
  add_foreign_key "lodge_payments", "parks"
  add_foreign_key "lodge_payments", "pitches"
  add_foreign_key "lodge_payments", "users"
  add_foreign_key "meter_readings", "pitches"
  add_foreign_key "meter_readings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "pitch_fees", "parks"
  add_foreign_key "pitch_fees", "pitches"
  add_foreign_key "pitch_fees", "users"
  add_foreign_key "pitches", "parks"
  add_foreign_key "pitches", "users"
  add_foreign_key "utilities", "parks"
  add_foreign_key "utilities", "pitches"
  add_foreign_key "utilities", "users"
  add_foreign_key "utility_rates", "parks"
end
