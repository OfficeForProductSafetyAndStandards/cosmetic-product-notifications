class DropVersions < ActiveRecord::Migration[5.2]
  def up
    drop_table :versions
  end

  def down
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
  end
end
