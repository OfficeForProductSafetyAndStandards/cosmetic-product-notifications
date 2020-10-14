class AddInvitationTokenAndInvitedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :users, bulk: true do |t|
        t.string :invitation_token
        t.datetime :invited_at, default: -> { "CURRENT_TIMESTAMP" }, null: false
      end
    end
  end
end
