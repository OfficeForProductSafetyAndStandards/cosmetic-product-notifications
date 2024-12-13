class AddLegacyRoleAndLegacyTypeToUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.string :legacy_role
        t.string :legacy_type
      end
    end
  end
end
