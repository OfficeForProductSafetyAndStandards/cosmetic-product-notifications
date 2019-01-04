class CreateNanomaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :nanomaterials do |t|
      t.string :name
      t.boolean :allowed_as_colourant
      t.boolean :allowed_as_uv_filter

      t.timestamps
    end
  end
end
