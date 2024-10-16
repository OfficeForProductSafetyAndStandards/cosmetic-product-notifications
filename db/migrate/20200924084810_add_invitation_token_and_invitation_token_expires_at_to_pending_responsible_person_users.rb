class AddInvitationTokenAndInvitationTokenExpiresAtToPendingResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_table :pending_responsible_person_users, bulk: true do |t|
        t.string :invitation_token
        t.datetime :invitation_token_expires_at
      end
      add_index :pending_responsible_person_users, :invitation_token, algorithm: :concurrently
    end
  end
end
