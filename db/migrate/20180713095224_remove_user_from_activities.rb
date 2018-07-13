class RemoveUserFromActivities < ActiveRecord::Migration[5.2]
  remove_reference :activities, :user, type: :uuid, foreign_key: true
end
