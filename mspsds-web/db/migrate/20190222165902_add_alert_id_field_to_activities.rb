class AddAlertIdFieldToActivities < ActiveRecord::Migration[5.2]
  def change
    add_reference :activities, :alert, index: false, foreign_key: true
  end
end
