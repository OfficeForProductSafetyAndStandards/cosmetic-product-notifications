class AddCategoryToComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :sub_sub_category, :integer
  end
end
