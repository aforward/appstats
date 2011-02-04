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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110204183259) do

  create_table "appstats_contexts", :force => true do |t|
    t.string   "context_key"
    t.string   "context_value"
    t.integer  "context_int"
    t.float    "context_float"
    t.integer  "appstats_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_entries", :force => true do |t|
    t.string   "action"
    t.datetime "occurred_at"
    t.text     "raw_entry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "appstats_log_collector_id"
  end

  create_table "appstats_log_collectors", :force => true do |t|
    t.string   "host"
    t.string   "filename"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
