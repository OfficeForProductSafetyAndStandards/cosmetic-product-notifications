class AddProjectToCase < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        change_table :investigations do |t|
          t.remove :question_type

          dir.up do
            t.string :case_type, null: false, default: "case"
            Investigation.all.each do |investigation|
              investigation.update! case_type: investigation.is_case ? "case" : "question"
            end
            t.remove :is_case
          end

          dir.down do
            t.boolean :is_case, null: false, default: true
            Investigation.all.each do |investigation|
              investigation.update! is_case: investigation.case_type == "case"
            end
            t.remove :case_type
          end
        end
      end
    end
  end
end
