class AddFormulationToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :exact_formulas do |t|
      t.string :inci_name
      t.decimal :quantity

      t.timestamps
    end

    add_reference :exact_formulas, :component, foreign_key: true, index: false
    add_index :exact_formulas, :component_id, algorithm: :concurrently

    create_table :range_formulas do |t|
      t.string :inci_name
      t.string :range

      t.timestamps
    end

    add_reference :range_formulas, :component, foreign_key: true, index: false
    add_index :range_formulas, :component_id, algorithm: :concurrently

    safety_assured do
      change_table :components, bulk: true do |t|
        t.string :notification_type
        t.string :frame_formulation
      end
    end

  end
end
