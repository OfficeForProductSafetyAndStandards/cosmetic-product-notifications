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

ActiveRecord::Schema.define(version: 2018_08_28_082107) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "activity_type", null: false
    t.integer "investigation_id"
    t.index ["investigation_id"], name: "index_activities_on_investigation_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "address_type", null: false
    t.string "line_1"
    t.string "line_2"
    t.string "locality"
    t.string "country"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "business_id"
    t.index ["business_id"], name: "index_addresses_on_business_id"
  end

  create_table "businesses", id: :serial, force: :cascade do |t|
    t.string "company_number"
    t.string "company_name", null: false
    t.string "company_type_code"
    t.string "nature_of_business_id"
    t.text "additional_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_number"], name: "index_businesses_on_company_number", unique: true
  end

  create_table "investigation_businesses", force: :cascade do |t|
    t.integer "business_id"
    t.integer "investigation_id"
    t.index ["business_id"], name: "index_investigation_businesses_on_business_id"
    t.index ["investigation_id", "business_id"], name: "index_on_investigation_id_and_business_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_businesses_on_investigation_id"
  end

  create_table "investigation_products", force: :cascade do |t|
    t.integer "investigation_id"
    t.integer "product_id"
    t.index ["investigation_id", "product_id"], name: "index_investigation_products_on_investigation_id_and_product_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_products_on_investigation_id"
    t.index ["product_id"], name: "index_investigation_products_on_product_id"
  end

  create_table "investigations", id: :serial, force: :cascade do |t|
    t.text "description"
    t.boolean "is_closed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "assignee_id"
    t.string "title", null: false
    t.string "risk_overview"
    t.integer "risk_level"
    t.integer "sensitivity"
    t.index ["assignee_id"], name: "index_investigations_on_assignee_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "gtin"
    t.string "name"
    t.text "description"
    t.string "model"
    t.string "batch_number"
    t.string "brand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_of_origin"
    t.date "date_placed_on_market"
    t.string "product_type"
  end

  create_table "rapex_images", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.index ["product_id"], name: "index_rapex_images_on_product_id"
  end

  create_table "rapex_imports", force: :cascade do |t|
    t.string "reference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.uuid "user_id"
    t.string "sourceable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sourceable_id"
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "item_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "activities", "investigations"
  add_foreign_key "addresses", "businesses"
  add_foreign_key "rapex_images", "products"
end
