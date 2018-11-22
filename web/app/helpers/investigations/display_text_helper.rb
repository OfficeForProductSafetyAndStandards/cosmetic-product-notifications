module Investigations::DisplayTextHelper
  def case_question_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def report_question_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end

  def get_highlight(highlights)
    highlight = pick_highlight(highlights)
    {
      label: get_highlight_title(highlight),
      content: get_highlight_content(highlight)
    }
  end

  def get_highlight_title(highlight)
    field_name = highlight[0]
    replace_unsightly_field_names(field_name).gsub('.', ', ').humanize
  end

  def replace_unsightly_field_names(field_name)
    return "Case id" if field_name == "pretty_id"
    field_name.gsub("search_index", "comment")
  end

  def get_highlight_content(highlight)
    highlighted_texts = highlight[1]
    highlighted_texts.first
  end

  private

  def pick_highlight(highlights)
    highlights.first
  end
end
