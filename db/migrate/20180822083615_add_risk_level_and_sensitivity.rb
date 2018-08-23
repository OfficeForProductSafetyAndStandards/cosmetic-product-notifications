class AddRiskLevelAndSensitivity < ActiveRecord::Migration[5.2]
  def change
    change_column :investigations, :risk_notes, :string
    rename_column :investigations, :risk_notes, :risk_overview
    add_column :investigations, :risk_level, :integer
    add_column :investigations, :sensitivity, :integer
  end
end
