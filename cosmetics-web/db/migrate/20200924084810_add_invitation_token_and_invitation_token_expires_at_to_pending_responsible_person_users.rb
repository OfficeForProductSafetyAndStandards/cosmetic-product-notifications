class AddInvitationTokenAndInvitationTokenExpiresAtToPendingResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :pending_responsible_person_users, :invitation_token, :string
    add_column :pending_responsible_person_users, :invitation_token_expires_at, :datetime
    add_index :pending_responsible_person_users, :invitation_token, algorithm: :concurrently
  end
end
