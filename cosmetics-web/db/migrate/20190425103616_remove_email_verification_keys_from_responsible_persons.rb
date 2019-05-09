class RemoveEmailVerificationKeysFromResponsiblePersons < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_index :email_verification_keys, :responsible_person_id
      remove_reference :email_verification_keys, :responsible_person
    end
  end
end
