class AddUserAttributes < ActiveRecord::Migration[5.2]
  create_table :user_attributes, id: false do |t|
    t.uuid :user_id, primary_key: true
    t.index :user_id
    t.boolean :has_viewed_introduction, default: false
    t.timestamps
  end
end
