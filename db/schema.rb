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

ActiveRecord::Schema.define(version: 2018_07_27_135256) do

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

  create_table "activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "investigation_id"
    t.uuid "activity_type_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type_id"], name: "index_activities_on_activity_type_id"
    t.index ["investigation_id"], name: "index_activities_on_investigation_id"
  end

  create_table "activity_types", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "businesses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "company_number"
    t.string "company_name", null: false
    t.string "company_type_code"
    t.string "registered_office_address_line_1"
    t.string "registered_office_address_line_2"
    t.string "registered_office_address_locality"
    t.string "registered_office_address_country"
    t.string "registered_office_address_postal_code"
    t.string "nature_of_business_id"
    t.text "additional_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_number"], name: "index_businesses_on_company_number", unique: true
  end

  create_table "images", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.uuid "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "investigation_businesses", force: :cascade do |t|
    t.uuid "investigation_id", null: false
    t.uuid "business_id", null: false
    t.index ["business_id"], name: "index_investigation_businesses_on_business_id"
    t.index ["investigation_id", "business_id"], name: "index_on_investigation_id_and_business_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_businesses_on_investigation_id"
  end

  create_table "investigation_products", force: :cascade do |t|
    t.uuid "investigation_id", null: false
    t.uuid "product_id", null: false
    t.index ["investigation_id", "product_id"], name: "index_investigation_products_on_investigation_id_and_product_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_products_on_investigation_id"
    t.index ["product_id"], name: "index_investigation_products_on_product_id"
  end

  create_table "investigations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.text "description"
    t.boolean "is_closed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "assignee_id"
    t.string "title", null: false
    t.text "risk_notes"
    t.index ["assignee_id"], name: "index_investigations_on_assignee_id"
  end

  create_table "products", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "gtin"
    t.string "name"
    t.text "description"
    t.string "model"
    t.string "mpn"
    t.string "batch_number"
    t.string "purchase_url"
    t.string "brand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
  end

  create_table "rapex_imports", force: :cascade do |t|
    t.string "reference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.uuid "user_id"
    t.uuid "sourceable_id"
    t.string "sourceable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "activities", "activity_types"
  add_foreign_key "activities", "investigations"
  add_foreign_key "images", "products"
end
