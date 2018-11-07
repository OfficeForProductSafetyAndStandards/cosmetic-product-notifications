class RenameTitleAsQuestionTitleInInvestigations < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :investigations, :title, :question_title
    end
  end
end
