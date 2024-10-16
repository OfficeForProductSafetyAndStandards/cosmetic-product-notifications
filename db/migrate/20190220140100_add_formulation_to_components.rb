class AddFormulationToComponents < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      create_table :exact_formulas do |t|
        t.string :inci_name
        t.decimal :quantity

        t.timestamps
      end

      add_reference :exact_formulas, :component, foreign_key: true, index: true

      create_table :range_formulas do |t|
        t.string :inci_name
        t.string :range

        t.timestamps
      end

      add_reference :range_formulas, :component, foreign_key: true, index: true

      change_table :components, bulk: true do |t|
        t.string :notification_type
        t.string :frame_formulation
      end
    end
  end
end
