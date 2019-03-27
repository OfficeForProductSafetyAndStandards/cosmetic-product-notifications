class CreateTests < ActiveRecord::Migration[5.2]
  def change
    create_table :tests, id: :serial do |t|
      t.string :type
      t.string :legislation
      t.string :result
      t.text :details
      t.date :date
      t.belongs_to :investigation, foreign_key: true, type: :integer
      t.belongs_to :product, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
