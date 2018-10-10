class AddReportersToInvestigations < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :reporter_name, :string
    add_column :investigations, :reporter_phone_number, :string
    add_column :investigations, :reporter_email_address, :string
    add_column :investigations, :reporter_type, :string
    add_column :investigations, :reporter_other_details, :text
  end
end
