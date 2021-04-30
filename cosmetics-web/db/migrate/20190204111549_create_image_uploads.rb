class CreateImageUploads < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      create_table :image_uploads do |t|
        t.string :filename
        t.timestamps
      end

      add_reference :image_uploads, :notification, foreign_key: true, index: true
    end
  end
end
