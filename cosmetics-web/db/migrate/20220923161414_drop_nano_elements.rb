class DropNanoElements < ActiveRecord::Migration[6.1]
  def change
    drop_table :nano_elements do |t|
      t.string :inci_name
      t.string :inn_name
      t.string :iupac_name
      t.string :xan_name
      t.string :cas_number
      t.string :ec_number
      t.string :einecs_number
      t.string :elincs_number
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.bigint :nano_material_id
      t.string :purposes, array: true
      t.string :confirm_toxicology_notified
      t.string :confirm_usage
      t.string :confirm_restrictions
      t.references :nano_material, foreign_key: true
    end
  end
end
