class RemoveExpiresAtFromPendingResponsiblePersonUsers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :pending_responsible_person_users, :expires_at, :datetime
    end
  end
end
