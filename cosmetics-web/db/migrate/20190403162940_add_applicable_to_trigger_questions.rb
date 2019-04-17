class AddApplicableToTriggerQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :trigger_questions, :applicable, :boolean
  end
end
