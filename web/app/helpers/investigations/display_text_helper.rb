module Investigations::DisplayTextHelper
  def case_question_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def report_question_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end

  def get_highlight_title(search_result)
    search_result.highlight.first[0]
  end

  def get_highlight_content(search_result)
    search_result.highlight.first[1][0]
  end
end
