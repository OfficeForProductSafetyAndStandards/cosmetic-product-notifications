module Investigations::DisplayTextHelper
  def case_question_lower_case_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def case_question_upper_case_text(investigation)
    investigation.is_case ? 'Case' : 'Question'
  end

  def report_question_lower_case_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end
end
