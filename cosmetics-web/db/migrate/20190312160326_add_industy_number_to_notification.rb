class AddIndustyNumberToNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :industry_reference, :string
  end
end
