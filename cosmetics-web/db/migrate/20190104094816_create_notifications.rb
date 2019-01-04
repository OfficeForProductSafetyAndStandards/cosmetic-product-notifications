class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :name
      t.boolean :is_imported
      t.string :imported_from

      t.timestamps
    end
  end
end
