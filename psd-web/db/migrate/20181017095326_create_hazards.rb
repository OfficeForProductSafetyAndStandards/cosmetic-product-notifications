class CreateHazards < ActiveRecord::Migration[5.2]
  def up
    safety_assured {
      change_table :investigations do |t|
        t.remove :risk_level, :risk_overview, :sensitivity
      end
    }
    create_table :hazards do |t|
      t.string :hazard_type
      t.string :description
      t.string :affected_parties
      t.integer :risk_level
      t.belongs_to :investigation, foreign_key: true, type: :integer
      t.timestamps
    end
  end

  def down
    change_table(:investigations, bulk: true) do |t|
      t.column :risk_level, :integer
      t.column :risk_overview, :string
      t.column :sensitivity, :integer
    end
  end
end
