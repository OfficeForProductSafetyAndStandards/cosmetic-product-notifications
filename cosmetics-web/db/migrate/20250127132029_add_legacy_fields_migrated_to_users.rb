class AddLegacyFieldsMigratedToUsers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.boolean :legacy_role_migrated, default: false
        t.boolean :legacy_type_migrated, default: false
      end
    end
  end
end
