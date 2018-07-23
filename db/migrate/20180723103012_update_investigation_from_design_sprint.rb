class UpdateInvestigationFromDesignSprint < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :title, :string, null: false, default: "Investigation"
    add_column :investigations, :risk_notes, :text
    remove_column :investigations, :severity, :string
  end
end
