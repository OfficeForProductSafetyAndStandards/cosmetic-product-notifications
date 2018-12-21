class AddPriorityToInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :investigations, bulk: true do |t|
        t.integer :priority
      end
    end
  end
end
