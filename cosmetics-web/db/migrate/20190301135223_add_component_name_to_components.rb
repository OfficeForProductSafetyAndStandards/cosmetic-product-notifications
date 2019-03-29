class AddComponentNameToComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :name, :string
  end
end
