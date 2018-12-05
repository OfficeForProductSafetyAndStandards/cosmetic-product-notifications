class RemoveFilesWithoutAttachmentsJob < ApplicationJob
  def perform
    ActiveStorage::Blob.all.select { |b| return b.attachments.empty? }.delete_all
  end
end
