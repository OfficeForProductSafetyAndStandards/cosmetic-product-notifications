class AddRoutingQuestionsAnswersToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :routing_questions_answers, :jsonb
  end
end
