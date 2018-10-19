class CreateHazards < ActiveRecord::Migration[5.2]
  def change
    create_table :investigations do |t|
      t.integer :risk_level, :sensitivity
      t.string :risk_overview
      t.timestamps
    end

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
