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

ActiveRecord::Schema[8.0].define(version: 2025_03_13_000001) do
  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.index ["category"], name: "index_collections_on_category"
  end

  create_table "feed_items", force: :cascade do |t|
    t.integer "feed_id", null: false
    t.string "title", null: false
    t.string "link", null: false
    t.text "description"
    t.datetime "published_at"
    t.string "guid"
    t.boolean "is_video", default: false
    t.boolean "is_audio", default: false
    t.string "author"
    t.string "categories"
    t.string "enclosure_url"
    t.string "enclosure_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id", "guid"], name: "index_feed_items_on_feed_id_and_guid", unique: true
    t.index ["feed_id"], name: "index_feed_items_on_feed_id"
    t.index ["published_at"], name: "index_feed_items_on_published_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.text "description"
    t.text "items", default: "[]"
    t.datetime "last_fetched_at"
    t.string "status"
    t.text "fetch_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "url"], name: "index_feeds_on_collection_id_and_url", unique: true
    t.index ["collection_id"], name: "index_feeds_on_collection_id"
  end

  add_foreign_key "feed_items", "feeds"
  add_foreign_key "feeds", "collections"
end
