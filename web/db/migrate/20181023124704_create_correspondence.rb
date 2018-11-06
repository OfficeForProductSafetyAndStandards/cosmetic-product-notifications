class CreateCorrespondence < ActiveRecord::Migration[5.2]
  def change
    create_table :correspondences do |t|
      t.string "correspondent_name"
      t.string "correspondent_type"
      t.string "contact_method"
      t.string "phone_number"
      t.string "email_address"
      t.date "correspondence_date"
      t.string "overview"
      t.text "details"
      t.belongs_to :investigation, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
