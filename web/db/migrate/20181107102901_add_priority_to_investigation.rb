class AddPriorityToInvestigation < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :investigations, bulk: true do |t|
        t.string :priority
        t.string :priority_rationale
      end
    end
  end
end
