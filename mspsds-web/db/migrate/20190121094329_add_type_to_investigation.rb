class AddTypeToInvestigation < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :type, :string
  end
end
