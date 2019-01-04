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

ActiveRecord::Schema.define(version: 2019_01_04_150537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cmr_materials", force: :cascade do |t|
    t.string "name"
    t.string "cas_registry_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_cmr_materials_on_component_id"
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.text "shades"
    t.boolean "contains_cmr"
    t.boolean "contains_nanomaterials"
    t.string "nanomaterial_application_method"
    t.string "nanomaterial_exposure"
    t.integer "category_1"
    t.integer "category_2"
    t.integer "category_3"
    t.integer "notification_type"
    t.integer "frame_formulation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notification_id"
    t.index ["notification_id"], name: "index_components_on_notification_id"
  end

  create_table "exact_formulas", force: :cascade do |t|
    t.string "inci_name"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_exact_formulas_on_component_id"
  end

  create_table "formula_files", force: :cascade do |t|
    t.string "filepath"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_formula_files_on_component_id", unique: true
  end

  create_table "image_files", force: :cascade do |t|
    t.string "filename"
    t.string "filepath"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notification_id"
    t.index ["notification_id"], name: "index_image_files_on_notification_id"
  end

  create_table "nanomaterials", force: :cascade do |t|
    t.string "name"
    t.boolean "allowed_as_colourant"
    t.boolean "allowed_as_uv_filter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_nanomaterials_on_component_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "name"
    t.boolean "is_imported"
    t.string "imported_from"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_person_id"
    t.index ["responsible_person_id"], name: "index_notifications_on_responsible_person_id"
  end

  create_table "range_formulas", force: :cascade do |t|
    t.string "inci_name"
    t.integer "range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_range_formulas_on_component_id"
  end

  create_table "responsible_people", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "postcode"
    t.string "email"
    t.string "phone"
    t.string "companies_house_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trigger_rule_answers", force: :cascade do |t|
    t.integer "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "component_id"
    t.index ["component_id"], name: "index_trigger_rule_answers_on_component_id"
  end

  add_foreign_key "cmr_materials", "components"
  add_foreign_key "components", "notifications"
  add_foreign_key "exact_formulas", "components"
  add_foreign_key "formula_files", "components"
  add_foreign_key "image_files", "notifications"
  add_foreign_key "nanomaterials", "components"
  add_foreign_key "notifications", "responsible_people"
  add_foreign_key "range_formulas", "components"
  add_foreign_key "trigger_rule_answers", "components"
end
