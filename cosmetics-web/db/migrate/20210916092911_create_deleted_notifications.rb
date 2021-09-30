class CreateDeletedNotifications < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      create_table :deleted_notifications, force: :cascade do |t|
        t.string "product_name"
        t.string "state"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.string "import_country"
        t.bigint "responsible_person_id"
        t.bigint "notification_id"
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
        t.index %w[cpnp_reference responsible_person_id], name: "index_deleted_notifications_on_cpnp_reference_and_rp_id", unique: true
        t.index %w[reference_number], name: "index_deleted_notifications_on_reference_number", unique: true
        t.index %w[responsible_person_id], name: "index_deleted_notifications_on_responsible_person_id"
      end
    end
  end
end
