class AddMoreEnquiryDetailsToInvestigations < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :date_received, :date
    add_column :investigations, :received_type, :string
  end
end
