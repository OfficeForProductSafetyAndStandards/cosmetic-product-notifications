class ChangeSourceInInvestigations < ActiveRecord::Migration[5.2]
  def change
    remove_column :investigations, :source, :string
  end
end
