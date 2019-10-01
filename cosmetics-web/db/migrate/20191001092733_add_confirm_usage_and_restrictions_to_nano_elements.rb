class AddConfirmUsageAndRestrictionsToNanoElements < ActiveRecord::Migration[5.2]
  def change
    change_table :nano_elements, bulk: true do |t|
      t.string :confirm_usage
      t.string :confirm_restrictions
    end
  end
end
