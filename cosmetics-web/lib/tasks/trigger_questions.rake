namespace :trigger_questions do
  desc "Deletes orphaned trigger questions and trigger question elements"
  task delete_orphaned: :environment do
    orphaned_trigger_questions = TriggerQuestion.where(component_id: nil)
    orphaned_elements = TriggerQuestionElement.where(trigger_question_id: nil)

    puts "Deleting #{orphaned_trigger_questions.count} orphaned trigger questions and #{orphaned_elements.count} orphaned trigger question elements"

    ActiveRecord::Base.transaction do
      orphaned_trigger_questions.destroy_all
      orphaned_elements.destroy_all
    end
  end
end
