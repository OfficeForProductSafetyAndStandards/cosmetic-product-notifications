module UrlHelper
  # IMAGES
  def associated_images_path(parent)
    polymorphic_path([parent, :images])
  end

  def associated_image_path(parent, image)
    associated_images_path(parent) + "/" + image.id.to_s
  end

  def new_associated_image_path(parent)
    associated_images_path(parent) + "/new"
  end

  def new_image_flow_path(parent)
    associated_images_path(parent) + "/new/new"
  end

  def edit_associated_image_path(parent, image)
    associated_image_path(parent, image) + "/edit"
  end

  def remove_associated_image_path(parent, image)
    associated_image_path(parent, image) + "/remove"
  end

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
end
