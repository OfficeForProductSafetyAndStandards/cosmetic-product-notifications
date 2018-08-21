class DropActivityTypes < ActiveRecord::Migration[5.2]
  def change
    # rename_column :activities, :activity_type, :activity_type_temp
    add_column :activities, :activity_type, :integer
    Activity.all.each { |activity|
      sql = "SELECT * FROM activity_types WHERE id = '#{activity.activity_type_id}'"
      activity.activity_type = ActiveRecord::Base.connection.select_all(sql).to_hash()[0]["name"]
      activity.save!
    }
    change_column_null :activities, :activity_type, false
    
    remove_reference :activities, :activity_type, index: true
    drop_table "activity_types", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "is_automatic", default: false, null: false
    end
  end


end
