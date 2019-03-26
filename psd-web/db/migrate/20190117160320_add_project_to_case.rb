class AddProjectToCase < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.remove :question_type
          t.rename :question_title, :user_title

          dir.up do
            t.string :type, default: "Investigation::Allegation"
            Investigation.all.each do |investigation|
              investigation.update! type: investigation.is_case ? "Investigation::Allegation" : "Investigation::Question"
            end
            t.remove :is_case
          end

          dir.down do
            t.boolean :is_case, null: false, default: true
            Investigation.all.each do |investigation|
              investigation.update! is_case: investigation.include?("Allegation")
            end
            t.remove :type
          end
        end
      end
    end
  end
end
