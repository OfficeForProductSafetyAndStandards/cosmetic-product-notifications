class AddHazardDescriptionAndNonCompliantReasonToCase < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_table :investigations, bulk: true do |t|
        t.text :hazard_description
        t.text :non_compliant_reason
      end
    end
  end
end
