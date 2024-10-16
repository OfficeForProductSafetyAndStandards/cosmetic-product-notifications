class CreateResponsiblePersons < ActiveRecord::Migration[5.2]
  def change
    create_table :responsible_persons do |t|
      t.string :account_type
      t.string :name
      t.string :companies_house_number
      t.string :email_address
      t.string :phone_number
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :county
      t.string :postal_code

      t.timestamps
    end
  end
end
