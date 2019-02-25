class CreateImageUploads < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :image_uploads do |t|
      t.string :filename
      t.timestamps
    end

    add_reference :image_uploads, :notification, foreign_key: true, index: false
    add_index :image_uploads, :notification_id, algorithm: :concurrently
  end
end
