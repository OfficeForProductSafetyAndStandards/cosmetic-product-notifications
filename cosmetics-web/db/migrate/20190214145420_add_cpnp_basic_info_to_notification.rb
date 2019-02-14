class AddCpnpBasicInfoToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :cpnp_reference, :string
    add_column :notifications, :cpnp_is_imported, :boolean
    add_column :notifications, :cpnp_imported_country, :string
    add_column :notifications, :shades, :string
  end
end
