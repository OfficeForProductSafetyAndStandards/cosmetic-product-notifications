class RemoveFilesWithoutAttachmentsJob < ApplicationJob
  def perform
    ActiveStorage::Blob.left_outer_joins(:attachments).merge(ActiveStorage::Attachment.where(id: nil)).delete_all
  end
end
