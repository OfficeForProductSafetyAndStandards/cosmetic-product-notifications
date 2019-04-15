module FileUploadConcern
  extend ActiveSupport::Concern

  # included do
  #   def self.add_upload_key(key, required)
  #     @upload_keys ||= []
  #     @upload_keys << [key, required] unless @upload_keys.include? [key, required]
  #   end
  #
  #   def self.get_upload_keys
  #     @upload_keys
  #   end
  #
  #   def self.enable_upload(key, required: true)
  #     self.class_eval do
  #       attribute "#{key}_file_id".to_sym
  #     end
  #
  #     after_initialize do
  #       self.class.add_upload_key(key, required)
  #     end
  #   end
  # end

  def update_blob_metadata(blob, metadata)
    return unless blob

    blob.metadata.update(metadata)
    blob.metadata["updated"] = Time.current
  end

  def validate_blob_size(blob, errors, blob_display_name)
    return unless blob && (blob.byte_size > max_file_byte_size)

    errors.add(:base, :file_too_large, message: "#{blob_display_name&.capitalize} is too big, allowed size is #{max_file_byte_size / 1.megabyte} MB")
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end

  def attach_blobs_to_list(*blobs, documents)
    blobs.each do |blob|
      next unless blob

      attachments = documents.attach(blob)
      attachment = attachments.last
      attachment.blob.save
    end
  end

  def attach_blob_to_attachment_slot(blob, attachment_slot)
    return unless blob

    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(blob)
    attachment_slot.blob.save
  end

private

  def file_id_symbol(key)
    "#{key}_file_id".to_sym
  end

  def get_file_id(key)
    self.send(file_id_symbol(key))
  end

  def set_file_id(key, value)
    self.send("#{key}_file_id=", value)
  end
end
