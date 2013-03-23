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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130323163344) do

  create_table "Elements", :force => true do |t|
    t.string   "category"
    t.string   "name"
    t.text     "content"
    t.text     "tags"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.text     "safe_content", :default => ""
    t.integer  "author",       :default => 1
  end

  create_table "courses", :force => true do |t|
    t.text     "name"
    t.text     "tags"
    t.text     "content",    :default => "[]"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.text     "tag",        :default => ""
    t.integer  "author",     :default => 1
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.text     "tags"
    t.text     "content"
    t.text     "markpolicy"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "author",     :default => 1
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user"
    t.integer  "course"
    t.text     "tag"
    t.text     "feedback"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "questions", :force => true do |t|
    t.string   "name"
    t.string   "parameters"
    t.string   "answers"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.text     "text",             :limit => 255
    t.string   "precision_regime",                :default => "s2"
    t.text     "tags",                            :default => ""
    t.text     "safe_text",                       :default => ""
    t.integer  "author",                          :default => 1
  end

  add_index "questions", ["name"], :name => "index_questions_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
    t.boolean  "author"
    t.text     "item_successes",  :default => "[]"
    t.string   "login_token"
    t.datetime "token_send_time"
    t.boolean  "confirmed",       :default => false
    t.text     "tag",             :default => ""
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
