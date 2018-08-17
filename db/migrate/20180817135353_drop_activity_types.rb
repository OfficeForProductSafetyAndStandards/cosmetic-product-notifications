class DropActivityTypes < ActiveRecord::Migration[5.2]
  def change
    remove_reference :activities, :activity_type, index: true
    add_column :activities, :activity_type, :integer, default: 0

    drop_table "activity_types", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "is_automatic", default: false, null: false
    end
  end
end
