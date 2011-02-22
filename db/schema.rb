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

ActiveRecord::Schema.define(:version => 20110222215437) do

  create_table "appstats_actions", :force => true do |t|
    t.string   "name"
    t.string   "plural_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_context_keys", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_context_values", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_contexts", :force => true do |t|
    t.string   "context_key"
    t.string   "context_value"
    t.integer  "context_int"
    t.float    "context_float"
    t.integer  "appstats_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appstats_contexts", ["context_key", "context_float"], :name => "index_appstats_contexts_on_context_key_and_context_float"
  add_index "appstats_contexts", ["context_key", "context_int"], :name => "index_appstats_contexts_on_context_key_and_context_int"
  add_index "appstats_contexts", ["context_key", "context_value"], :name => "index_appstats_contexts_on_context_key_and_context_value"
  add_index "appstats_contexts", ["context_key"], :name => "index_appstats_contexts_on_context_key"
  add_index "appstats_contexts", ["context_value"], :name => "index_appstats_contexts_on_context_value"

  create_table "appstats_entries", :force => true do |t|
    t.string   "action"
    t.datetime "occurred_at"
    t.text     "raw_entry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "appstats_log_collector_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "day"
    t.integer  "hour"
    t.integer  "min"
    t.integer  "sec"
  end

  add_index "appstats_entries", ["action"], :name => "index_appstats_entries_on_action"
  add_index "appstats_entries", ["year", "month", "day", "hour", "min"], :name => "index_entries_by_minute"
  add_index "appstats_entries", ["year", "month", "day", "hour"], :name => "index_entries_by_hour"
  add_index "appstats_entries", ["year", "month", "day"], :name => "index_entries_by_day"
  add_index "appstats_entries", ["year", "month"], :name => "index_entries_by_month"
  add_index "appstats_entries", ["year"], :name => "index_entries_by_year"

  create_table "appstats_hosts", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_log_collectors", :force => true do |t|
    t.string   "host"
    t.string   "filename"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appstats_log_collectors", ["host"], :name => "index_appstats_log_collectors_on_host"

  create_table "appstats_result_jobs", :force => true do |t|
    t.string   "name"
    t.string   "frequency"
    t.string   "status"
    t.text     "query"
    t.datetime "last_run_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_results", :force => true do |t|
    t.string   "name"
    t.string   "result_type"
    t.text     "query"
    t.text     "query_as_sql"
    t.integer  "count"
    t.string   "action"
    t.string   "host"
    t.integer  "page"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contexts"
  end

  add_index "appstats_results", ["action"], :name => "index_appstats_results_on_action"
  add_index "appstats_results", ["host"], :name => "index_appstats_results_on_host"
  add_index "appstats_results", ["name"], :name => "index_appstats_results_on_name"
  add_index "appstats_results", ["page"], :name => "index_appstats_results_on_page"

  create_table "appstats_test_objects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
