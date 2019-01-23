class CreateComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :components do |t|
      t.string :state
      t.string :shades, array: true

      t.timestamps
    end

    add_reference :components, :notification, foreign_key: true, index: false
    add_index :components, :notification_id, algorithm: :concurrently
  end
end
