class CreateInvestigationProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :investigation_products do |t|
      t.belongs_to :investigation, null: false, index: true, type: :uuid
      t.belongs_to :product, null: false, index: true, type: :uuid
    end

    add_index :investigation_products, [ :investigation_id, :product_id ], unique: true
  end
end
