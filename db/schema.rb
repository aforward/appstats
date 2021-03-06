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

ActiveRecord::Schema.define(:version => 20120118173343) do

  create_table "appstats_action_context_keys", :force => true do |t|
    t.string   "action_name"
    t.string   "context_key"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_actions", :force => true do |t|
    t.string   "name"
    t.string   "plural_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appstats_audits", :force => true do |t|
    t.string   "table_name"
    t.string   "column_type"
    t.string   "obj_name"
    t.string   "obj_attr"
    t.string   "obj_type"
    t.integer  "obj_id"
    t.string   "action"
    t.string   "old_value"
    t.string   "new_value"
    t.text     "old_value_full"
    t.text     "new_value_full"
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

  add_index "appstats_contexts", ["appstats_entry_id", "context_key", "context_float"], :name => "index_contexts_entry_key_float"
  add_index "appstats_contexts", ["appstats_entry_id", "context_key", "context_int"], :name => "index_contexts_entry_key_int"
  add_index "appstats_contexts", ["appstats_entry_id", "context_key", "context_value"], :name => "index_contexts_entry_key_value"
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
    t.integer  "week"
    t.integer  "quarter"
  end

  add_index "appstats_entries", ["action"], :name => "index_appstats_entries_on_action"
  add_index "appstats_entries", ["year", "month", "day", "hour", "min"], :name => "index_entries_by_minute"
  add_index "appstats_entries", ["year", "month", "day", "hour"], :name => "index_entries_by_hour"
  add_index "appstats_entries", ["year", "month", "day"], :name => "index_entries_by_day"
  add_index "appstats_entries", ["year", "month"], :name => "index_entries_by_month"
  add_index "appstats_entries", ["year", "quarter"], :name => "index_entries_by_quarter"
  add_index "appstats_entries", ["year", "week"], :name => "index_entries_by_week"
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
    t.string   "local_filename"
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
    t.string   "query_type"
  end

  create_table "appstats_results", :force => true do |t|
    t.string   "name"
    t.string   "result_type"
    t.text     "query"
    t.text     "query_to_sql"
    t.integer  "count"
    t.string   "action"
    t.string   "host"
    t.integer  "page"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contexts"
    t.text     "group_query_to_sql"
    t.string   "group_by"
    t.string   "query_type"
    t.string   "db_username"
    t.string   "db_name"
    t.string   "db_host"
    t.boolean  "is_latest"
    t.float    "query_duration_in_seconds"
    t.float    "group_query_duration_in_seconds"
  end

  add_index "appstats_results", ["action"], :name => "index_appstats_results_on_action"
  add_index "appstats_results", ["host"], :name => "index_appstats_results_on_host"
  add_index "appstats_results", ["is_latest"], :name => "index_appstats_results_on_is_latest"
  add_index "appstats_results", ["name"], :name => "index_appstats_results_on_name"
  add_index "appstats_results", ["page"], :name => "index_appstats_results_on_page"

  create_table "appstats_sub_results", :force => true do |t|
    t.integer  "appstats_result_id"
    t.string   "context_filter"
    t.integer  "count"
    t.float    "ratio_of_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appstats_sub_results", ["context_filter"], :name => "index_appstats_sub_results_on_context_filter"

  create_table "appstats_test_objects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.binary   "blah_binary"
    t.boolean  "blah_boolean"
    t.date     "blah_date"
    t.datetime "blah_datetime"
    t.decimal  "blah_decimal",   :precision => 10, :scale => 0
    t.float    "blah_float"
    t.integer  "blah_integer"
    t.string   "blah_string"
    t.text     "blah_text"
    t.time     "blah_time"
    t.datetime "blah_timestamp"
  end

end
