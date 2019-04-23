class RemoveIncidents < ActiveRecord::Migration[5.2]
  def up
    drop_table :incidents
  end

  def down
    create_table :incidents, id: :serial do |t|
      t.string :incident_type
      t.text :description
      t.date :date
      t.string :affected_party
      t.string :location
      t.belongs_to :investigation, index: true, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
