class AddWasNotifiedBeforeEuExitToNotifications < ActiveRecord::Migration[5.2]
  def change
    # safety_assured required to prevent warnings about adding a column with a
    # non null default rewriting the entire table
    safety_assured do
      add_column :notifications, :was_notified_before_eu_exit, :boolean, default: false
    end
  end
end
