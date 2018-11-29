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

ActiveRecord::Schema.define(version: 2018_11_29_123859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :serial, force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :serial, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.text "body"
    t.bigint "business_id"
    t.bigint "correspondence_id"
    t.datetime "created_at", null: false
    t.integer "investigation_id"
    t.bigint "product_id"
    t.string "title"
    t.string "type", default: "CommentActivity"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_activities_on_business_id"
    t.index ["correspondence_id"], name: "index_activities_on_correspondence_id"
    t.index ["investigation_id"], name: "index_activities_on_investigation_id"
    t.index ["product_id"], name: "index_activities_on_product_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "address_type", null: false
    t.integer "business_id"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "line_1"
    t.string "line_2"
    t.string "locality"
    t.string "postal_code"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_addresses_on_business_id"
  end

  create_table "businesses", id: :serial, force: :cascade do |t|
    t.text "additional_information"
    t.string "company_name", null: false
    t.string "company_number"
    t.string "company_status_code"
    t.string "company_type_code"
    t.datetime "created_at", null: false
    t.string "nature_of_business_id"
    t.datetime "updated_at", null: false
    t.index ["company_number"], name: "index_businesses_on_company_number", unique: true
  end

  create_table "corrective_actions", id: :serial, force: :cascade do |t|
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.date "date_decided"
    t.text "details"
    t.integer "investigation_id"
    t.string "legislation"
    t.integer "product_id"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_corrective_actions_on_business_id"
    t.index ["investigation_id"], name: "index_corrective_actions_on_investigation_id"
    t.index ["product_id"], name: "index_corrective_actions_on_product_id"
  end

  create_table "correspondences", force: :cascade do |t|
    t.string "contact_method"
    t.date "correspondence_date"
    t.string "correspondent_name"
    t.string "correspondent_type"
    t.datetime "created_at", null: false
    t.text "details"
    t.string "email_address"
    t.string "email_direction"
    t.string "email_subject"
    t.integer "investigation_id"
    t.string "overview"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_correspondences_on_investigation_id"
  end

  create_table "investigation_businesses", id: :serial, force: :cascade do |t|
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.integer "investigation_id"
    t.integer "relationship", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_investigation_businesses_on_business_id"
    t.index ["investigation_id", "business_id"], name: "index_on_investigation_id_and_business_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_businesses_on_investigation_id"
  end

  create_table "investigation_products", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "investigation_id"
    t.integer "product_id"
    t.datetime "updated_at", null: false
    t.index ["investigation_id", "product_id"], name: "index_investigation_products_on_investigation_id_and_product_id", unique: true
    t.index ["investigation_id"], name: "index_investigation_products_on_investigation_id"
    t.index ["product_id"], name: "index_investigation_products_on_product_id"
  end

  create_table "investigations", id: :serial, force: :cascade do |t|
    t.uuid "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_case", default: true, null: false
    t.boolean "is_closed", default: false
    t.integer "priority"
    t.string "question_title"
    t.string "question_type"
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_investigations_on_assignee_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "batch_number"
    t.string "brand"
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.date "date_placed_on_market"
    t.text "description"
    t.string "gtin"
    t.string "model"
    t.string "name"
    t.string "product_type"
    t.datetime "updated_at", null: false
  end

  create_table "rapex_imports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "reference", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reporters", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.integer "investigation_id"
    t.string "name"
    t.text "other_details"
    t.string "phone_number"
    t.string "reporter_type"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_reporters_on_investigation_id"
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "sourceable_id"
    t.string "sourceable_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "tests", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.text "details"
    t.integer "investigation_id"
    t.string "legislation"
    t.integer "product_id"
    t.string "result"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_tests_on_investigation_id"
    t.index ["product_id"], name: "index_tests_on_product_id"
  end

  add_foreign_key "activities", "businesses"
  add_foreign_key "activities", "correspondences"
  add_foreign_key "activities", "investigations"
  add_foreign_key "activities", "products"
  add_foreign_key "addresses", "businesses"
  add_foreign_key "corrective_actions", "businesses"
  add_foreign_key "corrective_actions", "investigations"
  add_foreign_key "corrective_actions", "products"
  add_foreign_key "correspondences", "investigations"
  add_foreign_key "reporters", "investigations"
  add_foreign_key "tests", "investigations"
  add_foreign_key "tests", "products"
end
