module Investigations::DisplayTextHelper
  def image_document_text(document)
    document.image? ? 'image' : 'document'
  end
  
  def investigation_sub_nav
    items = [{ href: investigation_url(@investigation), text: "Overview", active: @current == @investigation.pretty_id},
      { href: investigation_products_url(@investigation), text: "Products (#{@investigation.products.count})", active: @current == "products"},
      { href: investigation_businesses_url(@investigation), text: "Businesses (#{@investigation.businesses.count})", active: @current == "businesses"},
      { href: investigation_documents_url(@investigation), text: "Attachments (#{@investigation.documents.count})", active: @current == "documents"},
      { href: "/cases/#{@investigation.pretty_id}/activities", text: "Timeline", active: @current == "activities"}].compact
    render 'components/hmcts_subnav', title: "Summary", items: items
  end

  def investigation_sub_nav_tabs
    partial = case @current
    when "products"
      "investigations/tabs/products"
    when "businesses"
      "investigations/tabs/businesses"
    when "documents"
      "investigations/tabs/attachments"
    when "activities"
      "investigations/tabs/activity"
    else
      "investigations/tabs/overview"
    end
    render partial
  end

  def get_displayable_highlights(highlights, investigation)
    highlights.map do |highlight|
      get_best_highlight(highlight, investigation)
    end
  end

  def get_best_highlight(highlight, investigation)
    source = highlight[0]
    best_highlight = {
      label: pretty_source(source),
      content: gdpr_restriction_text
    }

    highlight[1].each do |result|
      unless should_be_hidden(result, source, investigation)
        best_highlight[:content] = get_highlight_content(result)
        return best_highlight
      end
    end

    best_highlight
  end

  def pretty_source(source)
    replace_unsightly_field_names(source).gsub('.', ', ')
  end

  def replace_unsightly_field_names(field_name)
    pretty_field_names = {
      pretty_id: "Case ID",
      "activities.search_index": "Activities, comment"
    }
    pretty_field_names[field_name.to_sym] || field_name.humanize
  end

  def get_highlight_content(result)
    sanitized_content = sanitize(result, tags: %w(em))
    sanitized_content.html_safe # rubocop:disable Rails/OutputSafety
  end

  def gdpr_restriction_text
    "GDPR protected details hidden"
  end

  def should_be_hidden(result, source, investigation)
    return true if correspondence_should_be_hidden(result, source, investigation)
    return true if (source.include? "complainant") && !investigation&.complainant&.can_be_displayed?

    false
  end

  def correspondence_should_be_hidden(result, source, investigation)
    return false unless source.include? "correspondences"

    key = source.partition('.').last
    sanitized_content = sanitize(result, tags: [])

    # If a result in its entirety appears in case correspondence that the user can see,
    # we probably don't care what was its source.
    investigation.correspondences.each do |c|
      return false if (c.send(key)&.include? sanitized_content) && c.can_be_displayed?
    end
    true
  end
end
