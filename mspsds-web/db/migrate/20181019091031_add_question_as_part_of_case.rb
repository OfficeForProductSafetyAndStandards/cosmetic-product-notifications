class AddQuestionAsPartOfCase < ActiveRecord::Migration[5.2]
  safety_assured do
    change_table :investigations, bulk: true do |t|
      t.boolean :is_case, null: false, default: true
      t.string :question_type
    end
  end
end
