class AddRoutingQuestionsAnswersToComponents < ActiveRecord::Migration[6.1]
  def change
    add_column :components, :routing_questions_answers, :jsonb
  end
end
