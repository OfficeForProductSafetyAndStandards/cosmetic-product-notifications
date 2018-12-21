class AddPrivateToCases < ActiveRecord::Migration[5.2]
  safety_assured do
    change_table :investigations, bulk: true do |t|
      t.boolean :is_private, null: false, default: false
    end
  end
end
