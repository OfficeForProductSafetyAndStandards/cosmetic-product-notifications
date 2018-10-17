class InitSchema < ActiveRecord::Migration[5.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "active_storage_attachments" do |t|
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.string "name", null: false
      t.bigint "record_id", null: false
      t.string "record_type", null: false
      t.index %w[blob_id], name: "index_active_storage_attachments_on_blob_id"
      t.index %w[record_type record_id name blob_id], name: "index_active_storage_attachments_uniqueness", unique: true
    end
    create_table "active_storage_blobs" do |t|
      t.bigint "byte_size", null: false
      t.string "checksum", null: false
      t.string "content_type"
      t.datetime "created_at", null: false
      t.string "filename", null: false
      t.string "key", null: false
      t.text "metadata"
      t.index %w[key], name: "index_active_storage_blobs_on_key", unique: true
    end
    create_table "activities", id: :serial do |t|
      t.integer "activity_type", null: false
      t.datetime "created_at", null: false
      t.integer "investigation_id"
      t.text "notes"
      t.datetime "updated_at", null: false
      t.index %w[investigation_id], name: "index_activities_on_investigation_id"
    end
    create_table "addresses", id: :serial do |t|
      t.string "address_type", null: false
      t.integer "business_id"
      t.string "country"
      t.datetime "created_at", null: false
      t.string "line_1"
      t.string "line_2"
      t.string "locality"
      t.string "postal_code"
      t.datetime "updated_at", null: false
      t.index %w[business_id], name: "index_addresses_on_business_id"
    end
    create_table "businesses", id: :serial do |t|
      t.text "additional_information"
      t.string "company_name", null: false
      t.string "company_number"
      t.string "company_type_code"
      t.datetime "created_at", null: false
      t.string "nature_of_business_id"
      t.datetime "updated_at", null: false
      t.index %w[company_number], name: "index_businesses_on_company_number", unique: true
    end
    create_table "investigation_businesses" do |t|
      t.integer "business_id"
      t.datetime "created_at", null: false
      t.integer "investigation_id"
      t.datetime "updated_at", null: false
      t.index %w[business_id], name: "index_investigation_businesses_on_business_id"
      t.index %w[investigation_id business_id], name: "index_on_investigation_id_and_business_id", unique: true
      t.index %w[investigation_id], name: "index_investigation_businesses_on_investigation_id"
    end
    create_table "investigation_products" do |t|
      t.datetime "created_at", null: false
      t.integer "investigation_id"
      t.integer "product_id"
      t.datetime "updated_at", null: false
      t.index %w[investigation_id product_id], name: "index_investigation_products_on_investigation_id_and_product_id", unique: true
      t.index %w[investigation_id], name: "index_investigation_products_on_investigation_id"
      t.index %w[product_id], name: "index_investigation_products_on_product_id"
    end
    create_table "investigations", id: :serial do |t|
      t.uuid "assignee_id"
      t.datetime "created_at", null: false
      t.text "description"
      t.boolean "is_closed", default: false
      t.integer "risk_level"
      t.string "risk_overview"
      t.integer "sensitivity"
      t.string "title", null: false
      t.datetime "updated_at", null: false
      t.index %w[assignee_id], name: "index_investigations_on_assignee_id"
    end
    create_table "products", id: :serial do |t|
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
    create_table "rapex_images", id: :serial do |t|
      t.datetime "created_at", null: false
      t.integer "product_id"
      t.string "title"
      t.datetime "updated_at", null: false
      t.string "url"
      t.index %w[product_id], name: "index_rapex_images_on_product_id"
    end
    create_table "rapex_imports" do |t|
      t.datetime "created_at", null: false
      t.string "reference", null: false
      t.datetime "updated_at", null: false
    end
    create_table "sources", id: :serial do |t|
      t.datetime "created_at", null: false
      t.string "name"
      t.integer "sourceable_id"
      t.string "sourceable_type"
      t.string "type"
      t.datetime "updated_at", null: false
      t.uuid "user_id"
      t.index %w[user_id], name: "index_sources_on_user_id"
    end
    create_table "versions" do |t|
      t.datetime "created_at"
      t.string "event", null: false
      t.integer "item_id"
      t.string "item_type", null: false
      t.text "object"
      t.text "object_changes"
      t.string "whodunnit"
      t.index %w[item_type item_id], name: "index_versions_on_item_type_and_item_id"
    end
    add_foreign_key "activities", "investigations"
    add_foreign_key "addresses", "businesses"
    add_foreign_key "rapex_images", "products"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
