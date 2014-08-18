# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140818184103) do

  create_table "apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quote_id"
    t.string   "tid"
    t.integer  "uid"
    t.string   "token"
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.string   "email"
    t.string   "license_number"
    t.string   "license_state"
    t.string   "vin"
    t.string   "registration"
    t.string   "us_insurance_company"
    t.string   "ownership"
  end

  add_index "apps", ["quote_id"], name: "index_apps_on_quote_id", using: :btree

  create_table "drivers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "token"
    t.integer  "app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drivers", ["app_id"], name: "index_drivers_on_app_id", using: :btree

  create_table "mio_js_sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mio_js_sessions", ["session_id"], name: "index_mio_js_sessions_on_session_id", unique: true, using: :btree
  add_index "mio_js_sessions", ["updated_at"], name: "index_mio_js_sessions_on_updated_at", using: :btree

  create_table "quotes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "enter_date"
    t.date     "leave_date"
    t.integer  "vehicle_type"
    t.integer  "year"
    t.integer  "make_id"
    t.integer  "model_id"
    t.integer  "value"
    t.integer  "towing"
    t.integer  "liability_limit"
    t.integer  "fixed_deductibles"
    t.integer  "body_style"
    t.integer  "liability"
    t.integer  "extended_travel"
    t.integer  "beyond_freezone"
    t.integer  "under21"
    t.integer  "uscoll_sc"
    t.integer  "days_veh_in_mexico"
    t.integer  "visit_reason"
    t.string   "other_model"
    t.string   "token"
  end

  add_index "quotes", ["token"], name: "index_quotes_on_token", unique: true, using: :btree

  create_table "toweds", force: true do |t|
    t.integer "type_id"
    t.integer "year"
    t.integer "value"
    t.integer "quote_id"
    t.string  "type_label"
    t.string  "make"
    t.string  "model"
    t.string  "license_plate"
    t.string  "license_plate_state"
    t.string  "vin"
  end

  add_index "toweds", ["quote_id"], name: "index_toweds_on_quote_id", using: :btree

end
