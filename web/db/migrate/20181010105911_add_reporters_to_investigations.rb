class AddReportersToInvestigations < ActiveRecord::Migration[5.2]
  def change
    create_table :reporters, id: :serial do |t|
      t.string :name
      t.string :phone_number
      t.string :email_address
      t.string :reporter_type, null: false
      t.text :other_details
    end
    add_reference :investigations, :reporter, index: false, null: true, foreign_key: true, type: :integer
  end
end
