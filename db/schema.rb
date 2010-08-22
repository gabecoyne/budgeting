# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100705234457) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "type"
    t.string   "bank"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buckets", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.float    "balance",    :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planned_buckets", :force => true do |t|
    t.integer  "planned_deposit_id"
    t.integer  "bucket_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planned_deposits", :force => true do |t|
    t.integer  "account_id"
    t.integer  "bucket_id"
    t.string   "name"
    t.float    "amount"
    t.date     "next"
    t.integer  "repeat"
    t.string   "repeat_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.integer  "account_id"
    t.integer  "bucket_id"
    t.float    "amount"
    t.date     "next"
    t.integer  "frequency"
    t.string   "frequency_type"
    t.boolean  "deposit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "bucket_id"
    t.datetime "date"
    t.string   "label"
    t.string   "notes"
    t.string   "status"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "mint_username"
    t.string   "mint_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
