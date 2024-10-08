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

ActiveRecord::Schema[7.1].define(version: 2024_10_08_153814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
  end

  create_table "cmrs", force: :cascade do |t|
    t.string "name"
    t.string "cas_number"
    t.string "ec_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_cmrs_on_component_id"
  end

  create_table "component_nano_materials", force: :cascade do |t|
    t.integer "component_id"
    t.integer "nano_material_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_component_nano_materials_on_component_id"
    t.index ["nano_material_id"], name: "index_component_nano_materials_on_nano_material_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "state"
    t.string "shades", array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.string "exposure_condition"
    t.string "exposure_routes", array: true
    t.jsonb "routing_questions_answers"
    t.string "notification_type_given_as"
    t.index ["notification_id"], name: "index_components_on_notification_id"
  end

  create_table "contact_persons", force: :cascade do |t|
    t.string "name"
    t.citext "email_address"
    t.string "phone_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_contact_persons_on_responsible_person_id"
  end

  create_table "deleted_notifications", force: :cascade do |t|
    t.string "product_name"
    t.string "state"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "import_country"
    t.bigint "responsible_person_id"
    t.bigint "notification_id"
    t.integer "reference_number"
    t.string "cpnp_reference"
    t.string "shades"
    t.string "industry_reference"
    t.datetime "cpnp_notification_date", precision: nil
    t.boolean "was_notified_before_eu_exit", default: false
    t.boolean "under_three_years"
    t.boolean "still_on_the_market"
    t.boolean "components_are_mixed"
    t.decimal "ph_min_value"
    t.decimal "ph_max_value"
    t.datetime "notification_complete_at", precision: nil
    t.text "csv_cache"
    t.index ["cpnp_reference", "responsible_person_id"], name: "index_deleted_notifications_on_cpnp_reference_and_rp_id", unique: true
    t.index ["notification_complete_at"], name: "index_deleted_notifications_on_notification_complete_at"
    t.index ["product_name"], name: "index_deleted_notifications_on_product_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["reference_number"], name: "index_deleted_notifications_on_reference_number", unique: true
    t.index ["responsible_person_id"], name: "index_deleted_notifications_on_responsible_person_id"
    t.index ["state"], name: "index_deleted_notifications_on_state"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "image_uploads", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "notification_id"
    t.index ["notification_id"], name: "index_image_uploads_on_notification_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.citext "inci_name", null: false
    t.string "cas_number"
    t.decimal "exact_concentration"
    t.string "range_concentration"
    t.boolean "poisonous", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.boolean "used_for_multiple_shades"
    t.decimal "minimum_concentration"
    t.decimal "maximum_concentration"
    t.index ["component_id"], name: "index_ingredients_on_component_id"
    t.index ["created_at"], name: "index_ingredients_on_created_at"
    t.index ["exact_concentration"], name: "index_ingredients_on_exact_concentration"
    t.index ["inci_name"], name: "index_ingredients_on_inci_name"
    t.index ["poisonous"], name: "index_ingredients_on_poisonous"
    t.index ["range_concentration"], name: "index_ingredients_on_range_concentration"
  end

  create_table "nano_materials", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "notification_id"
    t.string "inci_name"
    t.string "inn_name"
    t.string "iupac_name"
    t.string "xan_name"
    t.string "cas_number"
    t.string "ec_number"
    t.string "einecs_number"
    t.string "elincs_number"
    t.string "purposes", array: true
    t.string "confirm_toxicology_notified"
    t.string "confirm_usage"
    t.string "confirm_restrictions"
    t.bigint "nanomaterial_notification_id"
    t.index ["nanomaterial_notification_id"], name: "index_nano_materials_on_nanomaterial_notification_id"
    t.index ["notification_id", "nanomaterial_notification_id"], name: "index_nano_materials_on_notification_and_nano_notification", unique: true
    t.index ["notification_id"], name: "index_nano_materials_on_notification_id"
  end

  create_table "nanomaterial_notifications", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "responsible_person_id"
    t.text "user_id", null: false
    t.boolean "eu_notified"
    t.date "notified_to_eu_on"
    t.datetime "submitted_at", precision: nil
    t.index ["responsible_person_id"], name: "index_nanomaterial_notifications_on_responsible_person_id"
  end

  create_table "notification_delete_logs", force: :cascade do |t|
    t.uuid "submit_user_id"
    t.string "notification_product_name"
    t.integer "responsible_person_id"
    t.datetime "notification_created_at", precision: nil
    t.datetime "notification_updated_at", precision: nil
    t.string "cpnp_reference"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "reference_number"
    t.index ["responsible_person_id"], name: "index_notification_delete_logs_on_responsible_person_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "product_name"
    t.string "state"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "import_country"
    t.bigint "responsible_person_id"
    t.integer "reference_number"
    t.string "cpnp_reference"
    t.string "shades"
    t.datetime "cpnp_notification_date", precision: nil
    t.string "industry_reference"
    t.boolean "under_three_years"
    t.boolean "still_on_the_market"
    t.boolean "was_notified_before_eu_exit", default: false
    t.boolean "components_are_mixed"
    t.decimal "ph_min_value"
    t.decimal "ph_max_value"
    t.datetime "notification_complete_at", precision: nil
    t.text "csv_cache"
    t.datetime "deleted_at", precision: nil
    t.jsonb "routing_questions_answers"
    t.string "previous_state"
    t.integer "source_notification_id"
    t.string "archive_reason"
    t.index ["cpnp_reference", "responsible_person_id"], name: "index_notifications_on_cpnp_reference_and_rp_id", unique: true
    t.index ["notification_complete_at"], name: "index_notifications_on_notification_complete_at"
    t.index ["product_name"], name: "index_notifications_on_product_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["reference_number"], name: "index_notifications_on_reference_number", unique: true
    t.index ["responsible_person_id"], name: "index_notifications_on_responsible_person_id"
    t.index ["state"], name: "index_notifications_on_state"
  end

  create_table "pending_responsible_person_users", force: :cascade do |t|
    t.citext "email_address"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "responsible_person_id"
    t.string "invitation_token"
    t.datetime "invitation_token_expires_at", precision: nil
    t.uuid "inviting_user_id"
    t.string "name"
    t.index ["invitation_token"], name: "index_pending_responsible_person_users_on_invitation_token"
    t.index ["inviting_user_id"], name: "index_pending_responsible_person_users_on_inviting_user_id"
    t.index ["responsible_person_id", "email_address"], name: "index_pending_responsible_person_users_on_rp_and_email", unique: true
    t.index ["responsible_person_id"], name: "index_pending_responsible_person_users_on_responsible_person_id"
  end

  create_table "responsible_person_address_logs", force: :cascade do |t|
    t.string "line_1", null: false
    t.string "line_2"
    t.string "city", null: false
    t.string "county"
    t.string "postal_code", null: false
    t.datetime "start_date", precision: nil, null: false
    t.datetime "end_date", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id", null: false
    t.index ["responsible_person_id"], name: "index_responsible_person_address_logs_on_rp_id"
  end

  create_table "responsible_person_users", force: :cascade do |t|
    t.bigint "responsible_person_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "user_id", default: -> { "public.gen_random_uuid()" }
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "search_histories", force: :cascade do |t|
    t.string "query"
    t.integer "results"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sort_by"
  end

  create_table "trigger_question_elements", force: :cascade do |t|
    t.integer "answer_order"
    t.string "answer"
    t.integer "element_order"
    t.string "element"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "trigger_question_id"
    t.index ["trigger_question_id"], name: "index_trigger_question_elements_on_trigger_question_id"
  end

  create_table "trigger_questions", force: :cascade do |t|
    t.string "question"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "component_id"
    t.boolean "applicable"
    t.index ["component_id"], name: "index_trigger_questions_on_component_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "mobile_number"
    t.boolean "mobile_number_verified", default: false, null: false
    t.string "name"
    t.string "type"
    t.boolean "has_accepted_declaration", default: false
    t.citext "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.citext "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at", precision: nil
    t.integer "second_factor_attempts_count", default: 0
    t.datetime "second_factor_attempts_locked_at", precision: nil
    t.string "secondary_authentication_operation"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "invitation_token"
    t.datetime "invited_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "role"
    t.citext "new_email"
    t.string "new_email_confirmation_token"
    t.datetime "new_email_confirmation_token_expires_at", precision: nil
    t.boolean "account_security_completed", default: false
    t.string "unique_session_id"
    t.text "encrypted_totp_secret_key"
    t.integer "last_totp_at"
    t.string "secondary_authentication_methods", array: true
    t.integer "last_recovery_code_at"
    t.datetime "secondary_authentication_recovery_codes_generated_at", precision: nil
    t.string "secondary_authentication_recovery_codes", default: [], array: true
    t.string "secondary_authentication_recovery_codes_used", default: [], array: true
    t.datetime "deactivated_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["name"], name: "index_users_on_name"
    t.index ["new_email"], name: "index_users_on_new_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["type", "email"], name: "index_users_on_type_and_email", unique: true
    t.index ["type"], name: "index_users_on_type"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cmrs", "components"
  add_foreign_key "components", "notifications"
  add_foreign_key "contact_persons", "responsible_persons"
  add_foreign_key "image_uploads", "notifications"
  add_foreign_key "ingredients", "components"
  add_foreign_key "nano_materials", "nanomaterial_notifications"
  add_foreign_key "nanomaterial_notifications", "responsible_persons"
  add_foreign_key "notifications", "responsible_persons"
  add_foreign_key "pending_responsible_person_users", "responsible_persons"
  add_foreign_key "pending_responsible_person_users", "users", column: "inviting_user_id"
  add_foreign_key "responsible_person_address_logs", "responsible_persons"
  add_foreign_key "responsible_person_users", "responsible_persons"
  add_foreign_key "trigger_question_elements", "trigger_questions"
  add_foreign_key "trigger_questions", "components"
end
