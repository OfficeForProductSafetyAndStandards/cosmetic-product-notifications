class AddResponsiblePersonToNonStandardNanomaterials < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :non_standard_nanomaterials, :responsible_person, foreign_key: true, index: false
    add_index :non_standard_nanomaterials, :responsible_person_id, algorithm: :concurrently
  end
end
