class DropUserAttributes < ActiveRecord::Migration[7.0]
  def change
    drop_table :user_attributes do |t|
      t.datetime "declaration_accepted_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index %w[user_id], name: "index_user_attributes_on_user_id"
    end
  end
end
