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

ActiveRecord::Schema.define(version: 20131030202456) do

  create_table "generic_assets", force: true do |t|
    t.string   "main_title"
    t.string   "alt_title"
    t.string   "parallel_title"
    t.string   "series"
    t.string   "creator"
    t.string   "photographer"
    t.string   "author"
    t.string   "subjects"
    t.string   "type"
    t.string   "admin_replaces"
    t.string   "original_full_asset_path"
    t.string   "admin_conversion_spec"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
