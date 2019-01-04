class CreateImageFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :image_files do |t|
      t.string :filename
      t.string :filepath

      t.timestamps
    end
  end
end
