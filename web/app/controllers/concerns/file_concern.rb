module FileConcern
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :attachment_names, :file_params_key

  private

    def set_attachment_names(*names)
      @attachment_names = names
    end

    def set_file_params_key(key)
      @file_params_key = key
    end
  end

  def file_params_key
    check_correct_usage

    self.class.file_params_key
  end

  def attachment_names
    check_correct_usage

    self.class.attachment_names
  end

  def initialize_file_attachments
    attachment_names.each { |name| initialize_file_attachment name }
  end

  def load_file_attachments
    attachment_names.map { |name| load_file_attachment name }
  end

  def attach_files_to_list(documents, files = {})
    files.each do |attachment_name, file|
      attach_file_to_list(file, documents, attachment_name)
    end
  end

  def validate_blob_sizes(errors, files = {})
    files.each do |attachment_name, file|
      validate_blob_size(file, errors, attachment_name)
    end
  end

  def initialize_file_attachment(attachment_name = attachment_names.first)
    session[attachment_name] = nil
  end

  def load_file_attachment(attachment_name = attachment_names.first)
    return save_and_store_blob(attachment_name) if file_params(attachment_name)[attachment_name].present?
    return load_file_by_id attachment_name if session[attachment_name].present?
  end

  def save_and_store_blob(attachment_name = attachment_names.first)
    evaluated_file_params = file_params(attachment_name)[attachment_name]
    file = ActiveStorage::Blob.create_after_upload!(
      io: evaluated_file_params,
      filename: evaluated_file_params.original_filename,
      content_type: evaluated_file_params.content_type,
      metadata: file_metadata_params(attachment_name).to_h
    )
    session[attachment_name] = file.id
    file.analyze_later
    file
  end

  def load_file_by_id(attachment_name = attachment_names.first)
    ActiveStorage::Blob.find_by(id: session[attachment_name])
  end

  def attach_file_to_list(file, attachment_list, attachment_name = attachment_names.first)
    return unless file

    update_file_details(file, attachment_name)
    attachments = attachment_list.attach(file)
    attachment = attachments.last
    attachment.blob.save
    attachment
  end

  def attach_file_to_attachment_slot(file, attachment_slot, attachment_name = attachment_names.first)
    return unless file

    update_file_details(file, attachment_name)
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(file)
    attachment_slot.blob.save
  end

  def update_file_details(file, attachment_name = attachment_names.first)
    file.metadata.update(file_metadata_params(attachment_name))
    file.metadata["updated"] = Time.current
  end

  def validate_blob_size(blob, errors, attachment_name = attachment_names.first, allowed_size = max_file_byte_size)
    if blob && (blob.byte_size > allowed_size)
      errors.add(:base, :file_too_large, message: "#{attachment_name} is too big, allowed size is #{allowed_size / 1.megabyte}MB")
    end
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end

  def file_params(attachment_name = attachment_names.first)
    return {} if params[file_params_key].blank?

    params.require(file_params_key).permit(:file, attachment_name, :title, :description, :document_type, :other_type)
  end

  def check_correct_usage
    raise "file_params_key must be specified in #{self.class}" unless self.class.file_params_key
    raise "attachment_names must be specified in #{self.class}" unless self.class.attachment_names
  end

  def add_metadata(file, new_metadata)
    if file && new_metadata
      file.metadata.update(new_metadata)
      file.save
    end
  end

  def file_metadata_params(attachment_name = attachment_names.first)
    file_params.except(:file, attachment_name)
  end
end
