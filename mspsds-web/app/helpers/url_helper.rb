module UrlHelper
  # DOCUMENTS
  def associated_documents_path(parent)
    polymorphic_path([parent, :documents])
  end

  def associated_document_path(parent, document)
    associated_documents_path(parent) + "/" + document.id.to_s
  end

  def new_associated_document_path(parent)
    associated_documents_path(parent) + "/new"
  end

  def new_document_flow_path(parent)
    associated_documents_path(parent) + "/new/new"
  end

  def edit_associated_document_path(parent, document)
    associated_document_path(parent, document) + "/edit"
  end

  def remove_associated_document_path(parent, document)
    associated_document_path(parent, document) + "/remove"
  end

  def build_back_link_to_case
    case_id = request.referer&.match(/cases\/(\d+)/)&.captures&.first
    result = nil
    if case_id.present?
      result = { is_simple_link: true }
      investigation = Investigation.find(case_id)
      result[:simple_link_text] = "Back to #{investigation.pretty_description}"
      result[:link_to] = investigation
    end
    result
  end
end
