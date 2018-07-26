class CreateInvestigationBusinesses < ActiveRecord::Migration[5.2]
  def change
    create_table :investigation_businesses do |t|
      t.belongs_to :investigation, null: false, index: true, type: :uuid
      t.belongs_to :business, null: false, index: true, type: :uuid
    end

    add_index :investigation_businesses, [ :investigation_id, :business_id ], unique: true,
      name: "index_on_investigation_id_and_business_id"
  end
end
