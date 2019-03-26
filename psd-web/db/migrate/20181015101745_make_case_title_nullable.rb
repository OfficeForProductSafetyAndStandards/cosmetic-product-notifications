class MakeCaseTitleNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :investigations, :title, true
  end
end
