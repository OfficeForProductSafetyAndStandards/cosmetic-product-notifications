class RemoveIndexOnCompanyNumber < ActiveRecord::Migration[5.2]
  def change
    remove_index :businesses, :company_number
  end
end
