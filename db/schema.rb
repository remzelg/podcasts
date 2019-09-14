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

ActiveRecord::Schema.define(version: 2019_08_25_055538) do

  create_table "feeds", force: :cascade do |t|
    t.string "itunes_url", null: false
    t.string "itunes_title", null: false
    t.string "rss_url", null: false
    t.boolean "active", default: false
    t.boolean "out_of_date", default: false
    t.datetime "last_import_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itunes_title"], name: "index_feeds_on_itunes_title", unique: true
    t.index ["itunes_url"], name: "index_feeds_on_itunes_url", unique: true
    t.index ["rss_url"], name: "index_feeds_on_rss_url", unique: true
  end

  create_table "podcasts", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.string "author"
    t.string "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
