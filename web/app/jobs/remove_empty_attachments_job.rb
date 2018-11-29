class RemoveEmptyAttachmentsJob < ApplicationJob
  def perform
    ActiveStorage::Attachment.where(blob: nil).delete_all
  end
end
