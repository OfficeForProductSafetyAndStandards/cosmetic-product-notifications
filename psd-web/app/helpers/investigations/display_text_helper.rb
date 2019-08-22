module Investigations::DisplayTextHelper
  def image_document_text(document)
    document.image? ? 'image' : 'document'
  end

  def investigation_sub_nav(investigation)
    items = [{ href: investigation_url(investigation), text: "Overview", active: @current == @investigation.pretty_id },
             { href: investigation_products_url(investigation), text: "Products (#{@investigation.products.count})", active: @current == "products" },
             { href: investigation_businesses_url(investigation), text: "Businesses (#{@investigation.businesses.count})", active: @current == "businesses" },
             { href: investigation_documents_url(investigation), text: "Attachments (#{@investigation.documents.count})", active: @current == "documents" },
             { href: "/cases/#{@investigation.pretty_id}/activities", text: "Timeline", active: @current == "activities" }].compact
    render 'components/hmcts_subnav', title: "Summary", items: items
  end

  def investigation_sub_nav_tabs
    mapping = {
      products: :products,
      businesses: :businesses,
      documents: :attachments,
      activities: :activity
    }

    render 'investigations/tabs/' + mapping.fetch(@current.to_sym, :overview).to_s
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

  # rubocop:disable Rails/OutputSafety
  def investigation_assignee(investigation, classes = '')
    out = [investigation.assignee ? investigation.assignee.name.to_s : "Unassigned"]
    out << tag.div(investigation.assignee.organisation.name, class: classes) if investigation.assignee&.organisation.present?
    out.join.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def business_summary_list(business)
    rows = [
      { key: { text: 'Trading name' }, value: { text: business.trading_name } },
      { key: { text: 'Legal name' }, value: { text: business.legal_name } },
      { key: { text: 'Company number' }, value: { text: business.company_number } },
      { key: { text: 'Main address' }, value: { text: business.primary_location&.summary } },
      { key: { text: 'Main contact' }, value: { text: business.primary_contact&.summary } }
    ]

    # TODO PSD-693 Add primary authorities to businesses
    # { key: { text: 'Primary authority' }, value: { text: 'Suffolk Trading Standards' } }

    render 'components/govuk_summary_list', rows: rows
  end

  def complainant_summary_list(complainant)
    rows = [
      { key: { text: 'Name' }, value: { text: complainant.name } },
      { key: { text: 'Type' }, value: { text: complainant.complainant_type } },
      { key: { text: 'Phone' }, value: { text: complainant.phone_number } },
      { key: { text: 'Email' }, value: { text: complainant.email_address } },
      { key: { text: 'Other details' }, value: { text: complainant.other_details } }
    ]

    render 'components/govuk_summary_list', rows: rows
  end

  def correspondence_summary_list(correspondence, attachments: nil)
    rows = [
      { key: { text: 'Call with' }, value: { text: get_call_with_field(correspondence) } },
      { key: { text: 'Contains consumer info' }, value: { text: correspondence.has_consumer_info ? "Yes" : "No" } },
      { key: { text: 'Summary' }, value: { text: correspondence.overview } },
      { key: { text: 'Date' }, value: { text: correspondence.correspondence_date&.strftime("%d/%m/%Y") } },
      { key: { text: 'Content' }, value: { text: correspondence.details } },
      { key: { text: 'Attachments' }, value: { text: attachments } }
    ]

    render 'components/govuk_summary_list', rows: rows
  end

  def investigation_summary_list(investigation, include_actions: false, classes: '')
    rows = [
      {
        key: { text: 'Status', classes: classes },
        value: { text: investigation.status, classes: classes }
      },
      {
        key: { text: 'Assigned to', classes: classes },
        value: { text: investigation_assignee(investigation, classes) }
      },
      {
        key: { text: 'Last updated', classes: classes },
        value: { text: "#{time_ago_in_words(investigation.updated_at)} ago", classes: classes }
      }
    ]

    if include_actions
      rows[0][:actions] = [
        { href: status_investigation_path(investigation), text: 'Change', classes: classes, visually_hidden_text: 'status' }
      ]
      rows[1][:actions] = [
        { href: new_investigation_assign_path(investigation), text: 'Change', classes: classes, visually_hidden_text: 'assigned to' }
      ]
      rows[2][:actions] = [
        { href: new_investigation_activity_path(investigation), text: 'Add activity', classes: classes, visually_hidden_text: 'last updated' }
      ]
    end

    render 'components/govuk_summary_list', rows: rows
  end

  def product_summary_list(product, include_batch_number: false)
    rows = [
      { key: { text: 'Product name' }, value: { text: product.name } },
      { key: { text: 'Barcode / serial number' }, value: { text: product.product_code } },
      { key: { text: 'Type' }, value: { text: product.product_type } },
      include_batch_number ? { key: { text: 'Batch number' }, value: { text: @product.batch_number } } : nil,
      { key: { text: 'Category' }, value: { text: product.category } },
      { key: { text: 'Webpage' }, value: { text: product.webpage } },
      { key: { text: 'Country of origin' }, value: { text: country_from_code(product.country_of_origin) } },
      { key: { text: 'Description' }, value: { text: product.description } }
    ].compact

    render 'components/govuk_summary_list', rows: rows
  end

  def report_summary_list(investigation)
    rows = [
      { key: { text: 'Date recorded' }, value: { text: investigation.created_at.strftime("%d/%m/%Y") } }
    ]

    if investigation.allegation?
      rows << { key: { text: 'Product catgerory' }, value: { text: investigation.product_category } }
      rows << { key: { text: 'Hazard type' }, value: { text: investigation.hazard_type } }
    end

    render 'components/govuk_summary_list', rows: rows
  end
end
