class AddConfirmUsageAndRestrictionsToNanoElements < ActiveRecord::Migration[5.2]
  def change
    add_column :nano_elements, :confirm_usage, :string
    add_column :nano_elements, :confirm_restrictions, :string
  end
end
