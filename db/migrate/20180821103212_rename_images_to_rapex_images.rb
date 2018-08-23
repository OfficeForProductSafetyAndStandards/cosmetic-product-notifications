class RenameImagesToRapexImages < ActiveRecord::Migration[5.2]
  def change
    rename_table :images, :rapex_images
  end
end
