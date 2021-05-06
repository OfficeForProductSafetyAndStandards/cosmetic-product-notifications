class CreateTeamMembers < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      create_table :team_members do |t|
        t.string :user_id

        t.references :responsible_person, index: true, foreign_key: true

        t.timestamps
      end
    end
  end
end
