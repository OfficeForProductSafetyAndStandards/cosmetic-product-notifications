class CreateCorrectiveActions < ActiveRecord::Migration[5.2]
  def change
    create_table :corrective_actions, id: :serial do |t|
      t.string :legislation
      t.date :date_decided
      t.text :details
      t.text :summary
      t.belongs_to :investigation, foreign_key: true, type: :integer
      t.belongs_to :business, foreign_key: true, type: :integer
      t.belongs_to :product, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
