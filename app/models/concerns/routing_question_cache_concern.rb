module RoutingQuestionCacheConcern
  def save_routing_answer(question, answer)
    current_questions = routing_questions_answers || {}
    self.routing_questions_answers = current_questions.merge(question.to_s => answer.to_s)
    save
  end
end
