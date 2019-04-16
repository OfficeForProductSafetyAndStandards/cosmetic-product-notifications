class Document
  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_accessor :file_id, :integer
  attr_accessor :title, :string
  attr_accessor :description, :string
  attr_accessor :document_type, :string
  attr_accessor :filename, :string
  attr_accessor :parent

  validates :title, presence: true, on: [:update, :metadata]
  validate :validate_blob_size

  def initialize(attachment, required_fields=[:file_id])
    @file_id = attachment.is_a?(ActiveStorage::Attachment) ? attachment.blob_id : attachment.id if attachment
    @title = attachment.metadata["title"] if attachment&.metadata
    @description = attachment.metadata["description"] if attachment&.metadata
    @document_type = attachment.metadata["document_type"] if attachment&.metadata
    @filename = attachment.filename if attachment
  end

  def get_blob
    ActiveStorage::Blob.find(@file_id)
  end

  def update(params, context=:update)
    blob = get_blob
    @title = params[:title]
    @description = params[:description]

    if valid?(context)
      update_blob_metadata(blob, params)
      blob.save
      true
    else
      false
    end
  end

  def attach_blobs_to_list(documents)
    blob = get_blob
    attachments = documents.attach(blob)
    attachment = attachments.last
    attachment.blob.save
  end

  def detach_blob_from_list(documents)
    blob = get_blob
    attachment = documents.find { |doc| doc.blob_id == blob.id }
    attachment.destroy
  end

  def attach_blob_to_attachment_slot(attachment_slot)
    blob = get_blob
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(blob)
    attachment_slot.blob.save
  end

private

  def update_blob_metadata(blob, metadata)
    blob.metadata.update(metadata)
    blob.metadata["updated"] = Time.current
  end

  def validate_blob_size
    blob = get_blob
    return unless blob && (blob.byte_size > max_file_byte_size)

    errors.add(:base, :file_too_large, message: "File is too big, allowed size is #{max_file_byte_size / 1.megabyte} MB")
  end

  def max_file_byte_size
    100.megabytes
  end
end
