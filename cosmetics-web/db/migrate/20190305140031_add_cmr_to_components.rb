class AddCmrToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :cmrs do |t|
      t.string :name
      t.string :cas_number
      t.string :ec_number

      t.timestamps
    end

    add_reference :cmrs, :component, foreign_key: true, index: false
    add_index :cmrs, :component_id, algorithm: :concurrently
  end
end
