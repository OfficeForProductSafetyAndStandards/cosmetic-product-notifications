class AddAuditFieldsForActivities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :activities, :title, :string
    add_reference :activities, :business, foreign_key: true, index: false
    add_index :activities, :business_id, algorithm: :concurrently
    add_reference :activities, :product, index: false, foreign_key: true
    add_index :activities, :product_id, algorithm: :concurrently

    safety_assured do
      reversible do |dir|
        dir.up do
          drop_table :versions

          change_table :activities do |t|
            t.rename :description, :body
          end
        end

        dir.down do
          create_table "versions", id: :serial, force: :cascade do |t|
            t.datetime "created_at"
            t.string "event", null: false
            t.integer "item_id"
            t.string "item_type", null: false
            t.text "object"
            t.text "object_changes"
            t.string "whodunnit"
            t.index %w[item_type item_id], name: "index_versions_on_item_type_and_item_id"
          end

          change_table :activities do |t|
            t.rename :body, :description
          end
        end
      end
    end
  end
end
