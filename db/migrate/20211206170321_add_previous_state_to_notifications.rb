class AddPreviousStateToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :previous_state, :string
  end
end
