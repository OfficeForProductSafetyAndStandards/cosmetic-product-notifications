class MakeBusinessesCompanyNumberUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :businesses, :company_number, unique: true
  end
end
