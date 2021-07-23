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

ActiveRecord::Schema.define(version: 2021_07_15_141537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # These are custom enum types that must be created before they can be used in the schema definition
  create_enum "user_roles", ["poison_centre", "market_surveilance_authority"]

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
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
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
    t.bigint "notification_id", null: false
    t.string "notification_type"
    t.string "frame_formulation"
    t.string "sub_sub_category"
    t.string "name"
    t.string "physical_form"
    t.string "special_applicator"
    t.string "acute_poisoning_info"
    t.string "other_special_applicator"
    t.boolean "contains_poisonous_ingredients"
    t.float "minimum_ph"
    t.float "maximum_ph"
    t.text "ph"
    t.index ["notification_id"], name: "index_components_on_notification_id"
  end

  create_table "contact_persons", force: :cascade do |t|
    t.string "name"
    t.citext "email_address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_contact_persons_on_responsible_person_id"
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
    t.string "purposes", array: true
    t.string "confirm_toxicology_notified"
    t.string "confirm_usage"
    t.string "confirm_restrictions"
    t.index ["nano_material_id"], name: "index_nano_elements_on_nano_material_id"
  end

  create_table "nano_materials", force: :cascade do |t|
    t.string "exposure_condition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.string "exposure_routes", array: true
    t.index ["component_id"], name: "index_nano_materials_on_component_id"
  end

  create_table "nanomaterial_notifications", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.text "user_id", null: false
    t.boolean "eu_notified"
    t.date "notified_to_eu_on"
    t.datetime "submitted_at"
    t.index ["responsible_person_id"], name: "index_nanomaterial_notifications_on_responsible_person_id"
  end

  create_table "notification_delete_logs", force: :cascade do |t|
    t.uuid "submit_user_id"
    t.string "notification_product_name"
    t.integer "responsible_person_id"
    t.datetime "notification_created_at"
    t.datetime "notification_updated_at"
    t.string "cpnp_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reference_number"
    t.index ["responsible_person_id"], name: "index_notification_delete_logs_on_responsible_person_id"
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
    t.string "shades"
    t.string "industry_reference"
    t.datetime "cpnp_notification_date"
    t.boolean "was_notified_before_eu_exit", default: false
    t.boolean "under_three_years"
    t.boolean "still_on_the_market"
    t.boolean "components_are_mixed"
    t.decimal "ph_min_value"
    t.decimal "ph_max_value"
    t.datetime "notification_complete_at"
    t.text "csv_cache"
    t.index ["cpnp_reference", "responsible_person_id"], name: "index_notifications_on_cpnp_reference_and_rp_id", unique: true
    t.index ["reference_number"], name: "index_notifications_on_reference_number", unique: true
    t.index ["responsible_person_id"], name: "index_notifications_on_responsible_person_id"
  end

  create_table "pending_responsible_person_users", force: :cascade do |t|
    t.citext "email_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.string "invitation_token"
    t.datetime "invitation_token_expires_at"
    t.uuid "inviting_user_id"
    t.string "name"
    t.index ["invitation_token"], name: "index_pending_responsible_person_users_on_invitation_token"
    t.index ["inviting_user_id"], name: "index_pending_responsible_person_users_on_inviting_user_id"
    t.index ["responsible_person_id", "email_address"], name: "index_pending_responsible_person_users_on_rp_and_email", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", default: -> { "gen_random_uuid()" }
    t.index ["responsible_person_id"], name: "index_responsible_person_users_on_responsible_person_id"
  end

  create_table "responsible_persons", force: :cascade do |t|
    t.string "account_type"
    t.string "name"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "applicable"
    t.index ["component_id"], name: "index_trigger_questions_on_component_id"
  end

  create_table "user_attributes", primary_key: "user_id", id: :uuid, default: nil, force: :cascade do |t|
    t.datetime "declaration_accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_attributes_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "mobile_number"
    t.boolean "mobile_number_verified", default: false, null: false
    t.string "name"
    t.string "type"
    t.boolean "has_accepted_declaration", default: false
    t.citext "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.citext "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at"
    t.integer "second_factor_attempts_count", default: 0
    t.datetime "second_factor_attempts_locked_at"
    t.string "secondary_authentication_operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invited_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.enum "role", as: "user_roles"
    t.citext "new_email"
    t.string "new_email_confirmation_token"
    t.datetime "new_email_confirmation_token_expires_at"
    t.boolean "account_security_completed", default: false
    t.string "unique_session_id"
    t.text "encrypted_totp_secret_key"
    t.integer "last_totp_at"
    t.string "secondary_authentication_methods", array: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["new_email"], name: "index_users_on_new_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["type", "email"], name: "index_users_on_type_and_email", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cmrs", "components"
  add_foreign_key "components", "notifications"
  add_foreign_key "contact_persons", "responsible_persons"
  add_foreign_key "exact_formulas", "components"
  add_foreign_key "image_uploads", "notifications"
  add_foreign_key "nano_elements", "nano_materials"
  add_foreign_key "nano_materials", "components"
  add_foreign_key "nanomaterial_notifications", "responsible_persons"
  add_foreign_key "notification_files", "responsible_persons"
  add_foreign_key "notifications", "responsible_persons"
  add_foreign_key "pending_responsible_person_users", "responsible_persons"
  add_foreign_key "pending_responsible_person_users", "users", column: "inviting_user_id"
  add_foreign_key "range_formulas", "components"
  add_foreign_key "responsible_person_users", "responsible_persons"
  add_foreign_key "trigger_question_elements", "trigger_questions"
  add_foreign_key "trigger_questions", "components"
end
