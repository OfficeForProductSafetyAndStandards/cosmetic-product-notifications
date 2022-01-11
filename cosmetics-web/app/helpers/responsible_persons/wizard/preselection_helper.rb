module ResponsiblePersons::Wizard::PreselectionHelper
  def preselect_internal_reference_yes
    (params[:notification].present? && params[:notification][:add_internal_reference] == "yes") ||
      @notification.industry_reference.present?
  end

  def preselect_internal_reference_no
    model.routing_questions_answers[step.to_s] == "no"
  end

  def yes_no_checked(step, answer)
    answer_checked?(step, answer)
  end

  def answer_checked?(answer)
    model.routing_questions_answers && model.routing_questions_answers[step.to_s] == answer
  end
end
