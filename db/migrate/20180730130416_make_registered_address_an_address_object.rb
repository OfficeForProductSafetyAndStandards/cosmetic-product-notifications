class MakeRegisteredAddressAnAddressObject < ActiveRecord::Migration[5.2]
  def change
    remove_column :businesses, :registered_office_address_line_1, :string
    remove_column :businesses, :registered_office_address_line_2, :string
    remove_column :businesses, :registered_office_address_locality, :string
    remove_column :businesses, :registered_office_address_country, :string
    remove_column :businesses, :registered_office_address_postal_code, :string
  end
end
