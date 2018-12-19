module ActiveStorageAttachmentExtension
  def title
    blob.metadata["title"] if blob.present?
  end

  def description
    blob.metadata["description"] if blob.present?
  end

  def filename
    blob&.filename
  end

  def escaped_filename
    blob&.filename.to_s.gsub('_', '\_')
  end
end

Rails.configuration.to_prepare do
  ActiveStorage::Attachment.send :include, ::ActiveStorageAttachmentExtension
end
