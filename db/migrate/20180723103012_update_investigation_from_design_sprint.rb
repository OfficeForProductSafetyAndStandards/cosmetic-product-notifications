class UpdateInvestigationFromDesignSprint < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :title, :string
    add_column :investigations, :risk_notes, :text
    remove_column :investigations, :severity, :string

    Investigation.update_all(title: "Investigation")
    change_column :investigations, :title, :string, null: false
  end
end
