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

ActiveRecord::Schema.define(version: 2019_08_13_153818) do

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

  create_table "alerts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "investigation_id"
    t.string "summary"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_alerts_on_investigation_id"
  end

  create_table "businesses", id: :serial, force: :cascade do |t|
    t.string "company_number"
    t.datetime "created_at", null: false
    t.string "legal_name"
    t.string "trading_name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complainants", id: :serial, force: :cascade do |t|
    t.string "complainant_type"
    t.datetime "created_at", null: false
    t.string "email_address"
    t.integer "investigation_id"
    t.string "name"
    t.text "other_details"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_complainants_on_investigation_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "job_title"
    t.string "name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_contacts_on_business_id"
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
    t.boolean "has_consumer_info", default: false, null: false
    t.integer "investigation_id"
    t.string "overview"
    t.string "phone_number"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["investigation_id"], name: "index_correspondences_on_investigation_id"
  end

  create_table "investigation_businesses", id: :serial, force: :cascade do |t|
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.integer "investigation_id"
    t.string "relationship"
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
    t.uuid "assignable_id"
    t.string "assignable_type"
    t.string "complainant_reference"
    t.datetime "created_at", null: false
    t.date "date_received"
    t.text "description"
    t.text "hazard_description"
    t.string "hazard_type"
    t.boolean "is_closed", default: false
    t.boolean "is_private", default: false, null: false
    t.text "non_compliant_reason"
    t.string "pretty_id"
    t.string "product_category"
    t.string "received_type"
    t.string "type", default: "Investigation::Allegation"
    t.datetime "updated_at", null: false
    t.string "user_title"
    t.index ["assignable_type", "assignable_id"], name: "index_investigations_on_assignable_type_and_assignable_id"
    t.index ["pretty_id"], name: "index_investigations_on_pretty_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.integer "business_id"
    t.string "city"
    t.string "country"
    t.string "county"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "phone_number"
    t.string "postal_code"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_locations_on_business_id"
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "batch_number"
    t.string "category"
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "product_code"
    t.string "product_type"
    t.datetime "updated_at", null: false
    t.string "webpage"
  end

  create_table "rapex_imports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "reference", null: false
    t.datetime "updated_at", null: false
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

  create_table "user_attributes", primary_key: "user_id", id: :uuid, default: nil, force: :cascade do |t|
    t.boolean "boolean", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "has_accepted_declaration"
    t.boolean "has_been_sent_welcome_email"
    t.boolean "has_viewed_introduction", default: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_attributes_on_user_id"
  end

  add_foreign_key "activities", "businesses"
  add_foreign_key "activities", "correspondences"
  add_foreign_key "activities", "investigations"
  add_foreign_key "activities", "products"
  add_foreign_key "alerts", "investigations"
  add_foreign_key "complainants", "investigations"
  add_foreign_key "corrective_actions", "businesses"
  add_foreign_key "corrective_actions", "investigations"
  add_foreign_key "corrective_actions", "products"
  add_foreign_key "correspondences", "investigations"
  add_foreign_key "locations", "businesses"
  add_foreign_key "tests", "investigations"
  add_foreign_key "tests", "products"
end
