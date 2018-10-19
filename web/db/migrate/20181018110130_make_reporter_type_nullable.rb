class MakeReporterTypeNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :reporters, :reporter_type, true
  end
end
