class AddImportCountryToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :import_country, :string
  end
end
