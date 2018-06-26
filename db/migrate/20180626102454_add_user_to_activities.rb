class AddUserToActivities < ActiveRecord::Migration[5.2]
  def change
    add_reference :activities, :user, type: :uuid, foreign_key: true
  end
end
