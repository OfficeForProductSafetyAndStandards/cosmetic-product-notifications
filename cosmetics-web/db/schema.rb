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

ActiveRecord::Schema.define(version: 2019_04_03_134006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "cmrs", force: :cascade do |t|
    t.string "name"
    t.string "cas_number"
    t.string "ec_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_cmrs_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "state"
    t.string "shades", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notification_id"
    t.string "notification_type"
    t.string "frame_formulation"
    t.string "sub_sub_category"
    t.string "name"
    t.string "physical_form"
    t.string "special_applicator"
    t.string "acute_poisoning_info"
    t.index ["notification_id"], name: "index_components_on_notification_id"
  end

  create_table "contact_persons", force: :cascade do |t|
    t.string "name"
    t.string "email_address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_contact_persons_on_responsible_person_id"
  end

  create_table "email_verification_keys", force: :cascade do |t|
    t.string "key"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_email_verification_keys_on_responsible_person_id"
  end

  create_table "exact_formulas", force: :cascade do |t|
    t.string "inci_name"
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_exact_formulas_on_component_id"
  end

  create_table "image_uploads", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notification_id"
    t.index ["notification_id"], name: "index_image_uploads_on_notification_id"
  end

  create_table "nano_elements", force: :cascade do |t|
    t.string "inci_name"
    t.string "inn_name"
    t.string "iupac_name"
    t.string "xan_name"
    t.string "cas_number"
    t.string "ec_number"
    t.string "einecs_number"
    t.string "elincs_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nano_material_id"
    t.index ["nano_material_id"], name: "index_nano_elements_on_nano_material_id"
  end

  create_table "nano_materials", force: :cascade do |t|
    t.string "exposure_condition"
    t.string "exposure_route"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_nano_materials_on_component_id"
  end

  create_table "notification_files", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.string "user_id"
    t.string "upload_error"
    t.index ["responsible_person_id"], name: "index_notification_files_on_responsible_person_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "product_name"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "import_country"
    t.bigint "responsible_person_id"
    t.integer "reference_number"
    t.string "cpnp_reference"
    t.boolean "cpnp_is_imported"
    t.string "cpnp_imported_country"
    t.string "shades"
    t.string "industry_reference"
    t.datetime "cpnp_notification_date"
    t.boolean "was_notified_before_eu_exit", default: false
    t.boolean "under_three_years"
    t.boolean "still_on_the_market"
    t.boolean "components_are_mixed"
    t.decimal "ph_min_value"
    t.decimal "ph_max_value"
    t.index ["cpnp_reference", "responsible_person_id"], name: "index_notifications_on_cpnp_reference_and_rp_id", unique: true
    t.index ["reference_number"], name: "index_notifications_on_reference_number", unique: true
    t.index ["responsible_person_id"], name: "index_notifications_on_responsible_person_id"
  end

  create_table "pending_responsible_person_users", force: :cascade do |t|
    t.string "email_address"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_pending_responsible_person_users_on_responsible_person_id"
  end

  create_table "range_formulas", force: :cascade do |t|
    t.string "inci_name"
    t.string "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_range_formulas_on_component_id"
  end

  create_table "responsible_person_users", force: :cascade do |t|
    t.bigint "responsible_person_id"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["responsible_person_id"], name: "index_responsible_person_users_on_responsible_person_id"
  end

  create_table "responsible_persons", force: :cascade do |t|
    t.string "account_type"
    t.string "name"
    t.string "email_address"
    t.string "phone_number"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_email_verified", default: false
  end

  create_table "trigger_question_elements", force: :cascade do |t|
    t.integer "answer_order"
    t.string "answer"
    t.integer "element_order"
    t.string "element"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "trigger_question_id"
    t.index ["trigger_question_id"], name: "index_trigger_question_elements_on_trigger_question_id"
  end

  create_table "trigger_questions", force: :cascade do |t|
    t.string "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_trigger_questions_on_component_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cmrs", "components"
  add_foreign_key "components", "notifications"
  add_foreign_key "contact_persons", "responsible_persons"
  add_foreign_key "email_verification_keys", "responsible_persons"
  add_foreign_key "exact_formulas", "components"
  add_foreign_key "image_uploads", "notifications"
  add_foreign_key "nano_elements", "nano_materials"
  add_foreign_key "nano_materials", "components"
  add_foreign_key "notification_files", "responsible_persons"
  add_foreign_key "notifications", "responsible_persons"
  add_foreign_key "pending_responsible_person_users", "responsible_persons"
  add_foreign_key "range_formulas", "components"
  add_foreign_key "responsible_person_users", "responsible_persons"
  add_foreign_key "trigger_question_elements", "trigger_questions"
  add_foreign_key "trigger_questions", "components"
end
