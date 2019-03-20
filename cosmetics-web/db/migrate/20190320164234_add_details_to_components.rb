class AddDetailsToComponents < ActiveRecord::Migration[5.2]
  def change
    add_column :components, :physical_form, :string
    add_column :components, :special_applicator, :string
    add_column :components, :acute_poisoning_info, :string
  end
end
