class DropExactFormulasAndRangeFormulas < ActiveRecord::Migration[6.1]
  def change
    drop_table :exact_formulas do |t|
      t.string "inci_name", null: false
      t.decimal "quantity", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "component_id"
      t.references :components, foreign_key: true, type: :bigint
    end

    drop_table :range_formulas do |t|
      t.string "inci_name"
      t.string "range"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "component_id"
      t.references :components, foreign_key: true, type: :bigint
    end
  end
end
