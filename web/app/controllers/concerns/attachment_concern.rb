module AttachmentConcern
  extend ActiveSupport::Concern

  def images
    documents.select{|d| d.content_type == "image/png"}
  end
end
