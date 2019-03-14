class CreateAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :alerts, id: :serial do |t|
      t.string :summary
      t.text :description
      t.belongs_to :investigation, foreign_key: true, type: :integer
      t.timestamps
    end
  end
end
