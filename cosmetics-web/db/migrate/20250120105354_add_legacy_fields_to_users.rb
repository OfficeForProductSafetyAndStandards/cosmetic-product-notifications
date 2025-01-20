class AddLegacyFieldsToUsers < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      change_table :users, bulk: true do |t|
        t.string :legacy_role
        t.string :legacy_type
        t.string :corrected_email
      end
    end
  end

  def down
    safety_assured do
      change_table :users, bulk: true do |t|
        t.remove :legacy_role, :legacy_type, :corrected_email
      end
    end
  end
end
