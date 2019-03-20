class AddDetailsToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :under_three_years, :boolean
    add_column :notifications, :still_on_the_market, :boolean
  end
end
