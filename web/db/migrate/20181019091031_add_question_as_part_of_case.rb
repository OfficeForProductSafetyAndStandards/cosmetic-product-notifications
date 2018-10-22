class AddQuestionAsPartOfCase < ActiveRecord::Migration[5.2]
  def change
    change_table :investigations, bulk: true do |t|
      t.column :is_case, :boolean
      t.column :question_type, :string
    end
  end
end
