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
    highlights.map do |highlight|
      {
        label: get_highlight_title(highlight),
        content: get_highlight_content(highlight, investigation)
      }
    end
  end

  def get_highlight_title(highlight)
    field_name = highlight[0]
    replace_unsightly_field_names(field_name).gsub('.', ', ').humanize
  end

  def replace_unsightly_field_names(field_name)
    pretty_field_names = {
      pretty_id: "Case id",
      "activities.search_index": "Activities, comment"
    }
    pretty_field_names[field_name.to_sym] || field_name
  end

  def get_highlight_content(highlight, investigation)
    return gdpr_restriction_text(investigation) if should_be_hidden(highlight, investigation)

    highlighted_texts = highlight[1]
    sanitized_content = sanitize(highlighted_texts.first, tags: %w(em))
    sanitized_content.html_safe # rubocop:disable Rails/OutputSafety
  end

  def gdpr_restriction_text(investigation)
    source = investigation.source&.user&.organisation&.name || investigation.source&.user.full_name
    "This record contains sensitive data, contact #{source} for details"
  end

  def should_be_hidden(highlight, investigation)
    return true if correspondence_should_be_hidden(highlight, investigation)
    return true if (highlight[0].include? "reporter") && (!investigation.reporter.can_be_displayed?)
    false
  end

  def correspondence_should_be_hidden(highlight, investigation)
    return false unless highlight[0].include? "correspondences"

    key = highlight[0].partition('.').last
    highlighted_texts = highlight[1]
    sanitized_content = sanitize(highlighted_texts.first)
    investigation.correspondences.each do |c|
      # That means if 2 correspondences of a case have similar phone number, then highlight from both will get blocked
      # Since we don't actually hide the case this shouldn't be a massive problem
      #
      # The only other solution I can think of is to have 2 has_many correspondence lists on case, one sensitive
      # so elasticsearch gives us more specific highlights and we do the same but only for correspondence we know
      # is sensitive
      return true if (sanitized_content.include? c.send(key)) && (!c.can_be_displayed?)
    end
    false
  end
end
