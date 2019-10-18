class AddCpnpBasicInfoToNotification < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :notifications, bulk: true do |t|
        t.string :cpnp_reference
        t.boolean :cpnp_is_imported
        t.string :cpnp_imported_country
        t.string :shades
      end
    end
  end
end
