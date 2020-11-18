class AddInvitingUserToPendingResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :pending_responsible_person_users, :inviting_user, references: :users, foreign_key: { to_table: :users }, type: :uuid, index: false
    add_index :pending_responsible_person_users, :inviting_user_id, algorithm: :concurrently
  end
end
