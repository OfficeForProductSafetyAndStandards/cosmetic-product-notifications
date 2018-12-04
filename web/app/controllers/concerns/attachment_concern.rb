module AttachmentConcern
  extend ActiveSupport::Concern

  def images
    documents.select{|d| d.image?}
  end
end
