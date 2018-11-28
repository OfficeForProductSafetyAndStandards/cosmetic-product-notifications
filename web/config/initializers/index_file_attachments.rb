module ActiveStorageAttachmentExtension
  def title
    blob.metadata["title"]
  end

  def filename
    blob.filename
  end

  def description
    blob.metadata["description"]
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Attachment.send :include, ::ActiveStorageAttachmentExtension
end
