class CreateResponsiblePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :responsible_people do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :postcode
      t.string :email
      t.string :phone
      t.string :companies_house_number

      t.timestamps
    end
  end
end
