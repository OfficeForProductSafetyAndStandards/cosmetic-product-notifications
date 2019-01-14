module Investigations::DisplayTextHelper
  def case_question_text(investigation)
    investigation.is_case ? 'case' : 'question'
  end

  def report_question_text(investigation)
    investigation.is_case ? 'report' : 'question'
  end

  def image_document_text(document)
    document.image? ? 'image' : 'document'
  end

  def get_displayable_highlights(highlights, investigation)
    displayable_highlights = []
    highlights.each do |highlight|
      available_highlights = get_available_highlights(highlight, investigation)
      visible_results = available_highlights.reject { |r| r[:content] == gdpr_restriction_text }
      visible_results << available_highlights.first if visible_results.empty?
      displayable_highlights << visible_results.first
    end
    displayable_highlights
  end

  def get_available_highlights(highlight, investigation)
    results = []
    highlight[1].each do |result|
      results << {
        label: pretty_source(highlight[0]),
        content: get_highlight_content(result, highlight[0], investigation)
      }
    end
    results
  end

  def pretty_source(source)
    replace_unsightly_field_names(source).gsub('.', ', ').humanize
  end

  def replace_unsightly_field_names(field_name)
    pretty_field_names = {
      pretty_id: "Case id",
      "activities.search_index": "Activities, comment"
    }
    pretty_field_names[field_name.to_sym] || field_name
  end

  def get_highlight_content(result, source, investigation)
    return gdpr_restriction_text if should_be_hidden(result, source, investigation)

    sanitized_content = sanitize(result, tags: %w(em))
    sanitized_content.html_safe # rubocop:disable Rails/OutputSafety
  end

  def gdpr_restriction_text
    "GDPR protected details hidden"
  end

  def should_be_hidden(result, source, investigation)
    return true if correspondence_should_be_hidden(result, source, investigation)
    return true if (source.include? "reporter") && !investigation.reporter.can_be_displayed?

    false
  end

  def correspondence_should_be_hidden(result, source, investigation)
    return false unless source.include? "correspondences"

    key = source.partition('.').last
    sanitized_content = sanitize(result, tags: [])

    # If a result in its entirety appears in case correspondence that the user can see,
    # we probably don't care what was its source.
    investigation.correspondences.each do |c|
      return false if (c.send(key).include? sanitized_content) && c.can_be_displayed?
    end
    true
  end
end
