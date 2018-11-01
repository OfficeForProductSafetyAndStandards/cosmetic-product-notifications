class AddRelationshipToInvestigationBusinesses < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :investigation_businesses, :relationship, :integer, null: false, default: 0
    end
  end
end
