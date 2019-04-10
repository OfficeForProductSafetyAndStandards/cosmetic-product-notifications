class AddUserAttributes < ActiveRecord::Migration[5.2]
  create_table :user_attributes, id: false do |t|
    t.uuid :user_id, primary_key: true
    t.datetime :declaration_accepted_at

    t.timestamps
    t.index :user_id
  end
end
