class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.references :business, type: :uuid, foreign_key: true
      t.string :address_type, null: false
      t.string :line_1
      t.string :line_2
      t.string :locality
      t.string :country
      t.string :postal_code

      t.timestamps
    end
  end
end
