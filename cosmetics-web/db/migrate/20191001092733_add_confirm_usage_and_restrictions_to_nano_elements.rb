class AddConfirmUsageAndRestrictionsToNanoElements < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :nano_elements, bulk: true do |t|
        t.string :confirm_usage
        t.string :confirm_restrictions
      end
    end
  end
end
