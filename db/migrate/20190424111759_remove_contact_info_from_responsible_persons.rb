class RemoveContactInfoFromResponsiblePersons < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :responsible_persons do |t|
          dir.up do
            t.remove :email_address
            t.remove :phone_number
            t.remove :is_email_verified
          end
          dir.down do
            t.string :email_address
            t.string :phone_number
            t.boolean :is_email_verified
          end
        end
      end
    end
  end
end
