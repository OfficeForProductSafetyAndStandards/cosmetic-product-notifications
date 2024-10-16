class ChangeEmailToCitext < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      change_column :users, :email, :citext
      change_column :users, :new_email, :citext
      change_column :users, :unconfirmed_email, :citext
      change_column :contact_persons, :email_address, :citext
      change_column :pending_responsible_person_users, :email_address, :citext
    end
  end

  def down
    safety_assured do
      change_column :users, :email, :string
      change_column :users, :new_email, :string
      change_column :users, :unconfirmed_email, :string
      change_column :contact_persons, :email_address, :string
      change_column :pending_responsible_person_users, :email_address, :string
    end
  end
end
