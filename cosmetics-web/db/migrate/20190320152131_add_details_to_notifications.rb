class AddDetailsToNotifications < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :components, bulk: true do |_t|
        add_column :notifications, :under_three_years, :boolean
        add_column :notifications, :still_on_the_market, :boolean
      end
    end
  end
end
