class CreateHazards < ActiveRecord::Migration[5.2]
  def change
    safety_assured { change_table :investigations do |t|
      t.remove :risk_level, :risk_overview, :sensitivity, :who_is_at_risk
    end }
  
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