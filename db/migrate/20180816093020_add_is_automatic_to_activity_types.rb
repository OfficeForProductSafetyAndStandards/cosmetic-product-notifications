class AddIsAutomaticToActivityTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_types, :is_automatic, :boolean, default: false, null: false
  end
end
