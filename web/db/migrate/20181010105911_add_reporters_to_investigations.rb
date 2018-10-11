class AddReportersToInvestigations < ActiveRecord::Migration[5.2]
  def change
    change_table :investigations, bulk: true do |t|
      t.string :reporter_name
      t.string :reporter_phone_number
      t.string :reporter_email_address
      t.string :reporter_type
      t.text :reporter_other_details
    end
  end
end
