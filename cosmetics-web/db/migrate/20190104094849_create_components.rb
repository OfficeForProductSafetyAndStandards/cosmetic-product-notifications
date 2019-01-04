class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :components do |t|
      t.string :name
      t.text :shades
      t.boolean :contains_cmr
      t.boolean :contains_nanomaterials
      t.string :nanomaterial_application_method
      t.string :nanomaterial_exposure
      t.integer :category_1
      t.integer :category_2
      t.integer :category_3
      t.integer :notification_type
      t.integer :frame_formulation

      t.timestamps
    end
  end
end
