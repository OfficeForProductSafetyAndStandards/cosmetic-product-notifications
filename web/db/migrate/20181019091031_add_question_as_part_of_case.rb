class AddQuestionAsPartOfCase < ActiveRecord::Migration[5.2]
  def change
    add_column :investigations, :is_case, :boolean
    add_column :investigations, :question_type, :string
  end
end
