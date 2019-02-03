class RenameReporterToComplainant < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :reporters, :reporter_type, :complainant_type
      rename_table :reporters, :complainants
    end
  end
end
