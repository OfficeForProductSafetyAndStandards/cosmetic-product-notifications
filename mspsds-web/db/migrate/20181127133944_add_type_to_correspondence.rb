class AddTypeToCorrespondence < ActiveRecord::Migration[5.2]
  def change
    add_column :correspondences, :type, :string
  end
end
