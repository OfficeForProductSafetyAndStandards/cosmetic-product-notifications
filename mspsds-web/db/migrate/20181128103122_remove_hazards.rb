class RemoveHazards < ActiveRecord::Migration[5.2]
  def up
    drop_table :hazards
  end

  def down
    create_table :hazards do |t|
      t.string :hazard_type
      t.string :description
      t.string :affected_parties
      t.integer :risk_level
      t.belongs_to :investigation, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
