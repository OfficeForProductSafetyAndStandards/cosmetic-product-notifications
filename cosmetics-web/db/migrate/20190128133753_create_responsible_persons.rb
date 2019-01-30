class CreateResponsiblePersons < ActiveRecord::Migration[5.2]
  def change
    create_table :responsible_persons do |t|
      t.string :name
      t.string :address
      t.string :email_address
      t.string :phone_number

      t.timestamps
    end
  end
end
