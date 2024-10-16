class AddEmailVerifiedFlagToResponsiblePerson < ActiveRecord::Migration[5.2]
  def change
    # safety_assured required to prevent warnings about adding a column with a
    # non null default rewriting the entire table
    safety_assured do
      add_column :responsible_persons, :is_email_verified, :boolean, default: false
    end
  end
end
