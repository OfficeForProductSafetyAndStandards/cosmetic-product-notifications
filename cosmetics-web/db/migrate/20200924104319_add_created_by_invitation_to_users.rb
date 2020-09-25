class AddCreatedByInvitationToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :users, :created_by_invitation, :boolean, default: false
    end
  end
end
