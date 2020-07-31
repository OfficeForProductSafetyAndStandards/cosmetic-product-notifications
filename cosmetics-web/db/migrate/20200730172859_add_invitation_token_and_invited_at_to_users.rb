class AddInvitationTokenAndInvitedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :users, :invitation_token, :string
      add_column :users, :invited_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }, null: false
    end
  end
end
