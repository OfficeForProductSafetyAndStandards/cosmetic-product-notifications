class AddResponsiblePersonToNotifications < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :notifications, :responsible_person, foreign_key: true, index: true
    end
  end
end
