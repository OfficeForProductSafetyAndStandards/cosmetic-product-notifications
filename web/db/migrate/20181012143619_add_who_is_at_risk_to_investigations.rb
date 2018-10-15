class AddWhoIsAtRiskToInvestigations < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :who_is_at_risk, :string
  end
end
