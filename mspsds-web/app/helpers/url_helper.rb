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
    result = { is_simple_link: request.referrer.match?(/cases\/\d/) }
    if result[:is_simple_link]
      case_id = request.referrer.split(/cases\//)[1].split(/[?\/#]/)[0]
      kase = Investigation.find(case_id)
      result[:simple_link_text] = "Bask to #{kase.pretty_description}"
      result[:link_to] = kase
    end
    result
  end
end
