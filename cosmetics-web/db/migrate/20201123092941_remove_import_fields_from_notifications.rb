class RemoveImportFieldsFromNotifications < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :notifications, :cpnp_is_imported, :boolean
      remove_column :notifications, :cpnp_imported_country, :string
    end
  end
end
