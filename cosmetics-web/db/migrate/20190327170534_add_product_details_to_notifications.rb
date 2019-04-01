class AddProductDetailsToNotifications < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :notifications, bulk: true do |_t|
        add_column :notifications, :components_are_mixed, :boolean
        add_column :notifications, :ph_min_value, :decimal
        add_column :notifications, :ph_max_value, :decimal
      end
    end
  end
end
