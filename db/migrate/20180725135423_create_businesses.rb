class CreateBusinesses < ActiveRecord::Migration[5.2]
  def change
    create_table :businesses, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :company_number
      t.string :company_name, null: false
      t.string :company_type
      t.string :registered_office_address_line_1
      t.string :registered_office_address_line_2
      t.string :registered_office_address_locality
      t.string :registered_office_address_country
      t.string :registered_office_address_postal_code
      t.string :nature_of_business_id
      t.text :additional_information

      t.timestamps
    end
  end
end
