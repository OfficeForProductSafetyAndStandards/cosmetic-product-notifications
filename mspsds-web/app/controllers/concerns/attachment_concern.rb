module AttachmentConcern
  extend ActiveSupport::Concern

  def images
    documents.select(&:image?)
  end
end
