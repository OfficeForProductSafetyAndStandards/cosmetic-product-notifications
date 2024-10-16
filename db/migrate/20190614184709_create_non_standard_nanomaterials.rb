class CreateNonStandardNanomaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :non_standard_nanomaterials do |t|
      t.string :iupac_name

      t.timestamps
    end
  end
end
