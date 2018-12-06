class RemoveFilesWithoutAttachmentsJob < ApplicationJob
  def perform
    good_blob_ids = ActiveStorage::Attachment.select("blob_id")
    ActiveStorage::Blob.where.not(id: good_blob_ids).delete_all
  end
end
