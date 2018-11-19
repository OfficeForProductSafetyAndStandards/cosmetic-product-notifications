module FileConcern
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :attachment_categories, :file_params_key

  private

    def set_attachment_categories(*filenames)
      @attachment_categories = filenames
    end

    def set_file_params_key(key)
      @file_params_key = key
    end
  end

  def file_params_key
    check_correct_implementation
    # raise "file_params_key must be specified in #{self.class}" unless self.class.attachment_categories

    self.class.file_params_key
  end

  def attachment_categories
    check_correct_implementation
    # raise "file_params_key must be specified in #{self.class}" unless self.class.attachment_categories

    self.class.attachment_categories
  end

  def initialize_file_attachments
    attachment_categories.each { |category| session[category] = nil }
  end

  def load_file_attachments
    attachment_categories.map { |category| load_file_attachment category }
  end

  def attach_files_to_list(documents, files = {})
    files.each do |attachment_category, file|
      attach_file_to_list(file, documents, attachment_category)
    end
  end

  def validate_blob_sizes(errors, files = {})
    files.each do |attachment_category, file|
      validate_blob_size(file, errors, attachment_category)
    end
  end

  def initialize_file_attachment(attachment_category = attachment_categories.first)
    session[attachment_category] = nil
  end

  def load_file_attachment(attachment_category = attachment_categories.first)
    return save_and_store_blob(attachment_category) if file_params(attachment_category)[attachment_category].present?
    return load_file_by_id attachment_category if session[attachment_category].present?
  end

  def save_and_store_blob(attachment_category = attachment_categories.first)
    evaluated_file_params = file_params(attachment_category)[attachment_category]
    file = ActiveStorage::Blob.create_after_upload!(
      io: evaluated_file_params,
      filename: evaluated_file_params.original_filename,
      content_type: evaluated_file_params.content_type,
      metadata: file_metadata_params(attachment_category).to_h
    )
    session[attachment_category] = file.id
    file.analyze_later
    file
  end

  def load_file_by_id(attachment_category = attachment_categories.first)
    ActiveStorage::Blob.find_by(id: session[attachment_category])
  end

  def attach_file_to_list(file, attachment_list, attachment_category = attachment_categories.first)
    return unless file

    update_file_details(file, attachment_category)
    attachments = attachment_list.attach(file)
    attachment = attachments.last
    attachment.blob.save
    attachment
  end

  def attach_file_to_attachment_slot(file, attachment_slot, attachment_category = attachment_categories.first)
    return unless file

    update_file_details(file, attachment_category)
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(file)
    attachment_slot.blob.save
  end

  def update_file_details(file, attachment_category = attachment_categories.first)
    file_metadata = file_params(attachment_category).merge(attachment_category: attachment_category)
    file.metadata.update(file_metadata)
    file.metadata["updated"] = Time.current
  end

  def validate_blob_size(blob, errors, attachment_category = attachment_categories.first, allowed_size = max_file_byte_size)
    if blob && (blob.byte_size > allowed_size)
      errors.add(:base, :file_too_large, message: "#{attachment_category} is too big, allowed size is #{allowed_size / 1.megabyte}MB")
    end
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end

  def file_params(attachment_category = attachment_categories.first)
    return {} if params[file_params_key].blank?

    params.require(file_params_key).permit(:file, attachment_category, :title, :description, :document_type, :other_type, :overview, :attachment_description)
  end

  def check_correct_implementation
    raise "file_params_key must be specified in #{self.class}" unless self.class.file_params_key
    raise "attachment_categories must be specified in #{self.class}" unless self.class.attachment_categories
  end

  def file_metadata_params(attachment_category = attachment_categories.first)
    title = file_params(attachment_category)[:overview]
    if attachment_category == :email_file
      description = "Original email as a file"
    elsif attachment_category == :email_attachment
      description = file_params(attachment_category)[:attachment_description]
    end
    file_params(attachment_category).except(attachment_category).merge(title: title, description: description)
  end
end
