class AddCompanyStatusToBusinesses < ActiveRecord::Migration[5.2]
  def change
    add_column :businesses, :company_status_code, :string
  end
end
