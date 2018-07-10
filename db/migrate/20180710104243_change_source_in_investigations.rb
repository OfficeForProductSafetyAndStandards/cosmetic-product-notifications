class ChangeSourceInInvestigations < ActiveRecord::Migration[5.2]
  def change
    remove_column :investigations, :source, :string
    add_reference :investigations, :source, type: :uuid, foreign_key: true
  end
end
