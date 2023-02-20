namespace :trigger_questions do
  desc "Deletes dangling trigger questions and trigger question elements"
  task delete_dangling: :environment do
    dangling_trigger_questions = TriggerQuestion.where(component_id: nil)
    dangling_elements = TriggerQuestionElement.where(trigger_question_id: nil)

    puts "Deleting #{dangling_trigger_questions.count} dangling trigger questions and #{dangling_elements.count} dangling trigger question elements"

    ActiveRecord::Base.transaction do
      dangling_trigger_questions.destroy_all
      dangling_elements.destroy_all
    end
  end
end
