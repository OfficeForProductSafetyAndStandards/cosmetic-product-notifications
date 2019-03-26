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
    case_id = request.referer&.match(/cases\/(\d+-\d+)/)&.captures&.first
    return nil if case_id.blank?

    investigation = Investigation.find_by!(pretty_id: case_id)
    {
      is_simple_link: true,
      text: "Back to #{investigation.pretty_description}",
      href: investigation
    }
  end
end
