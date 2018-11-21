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
    attachment_names.each { |name| session[name] = nil }
  end

  def load_file_attachments
    attachment_names.map do |name|
      specific_file_params = file_params(name)[name]

      unless specific_file_params.present?
        if session[name].present?
          return ActiveStorage::Blob.find_by(id: session[name])
        else
          return
        end
      end

      specific_metadata_params = specific_file_params.except(:file, name)
      file = ActiveStorage::Blob.create_after_upload!(
          io: specific_file_params,
          filename: specific_file_params.original_filename,
          content_type: specific_file_params.content_type,
          metadata: specific_metadata_params.to_h
      )
      session[name] = file.id
      file.analyze_later
      file
    end
  end

  def attach_files_to_list(documents, files = {})
    files.each do |attachment_name, file|
      attach_file_to_list(file, documents, attachment_name)
    end
  end

  def attach_file_to_list(file, attachment_list, attachment_name)
    return unless file

    update_file_details(file, attachment_name)
    attachments = attachment_list.attach(file)
    attachment = attachments.last
    attachment.blob.save
    attachment
  end

  def attach_file_to_attachment_slot(file, attachment_slot, attachment_name)
    return unless file

    update_file_details(file, attachment_name)
    attachment_slot.detach if attachment_slot.attached?
    attachment_slot.attach(file)
    attachment_slot.blob.save
  end

  def update_file_details(file, attachment_name)
    file.metadata.update(file_metadata_params(attachment_name))
    file.metadata["updated"] = Time.current
  end


  def file_params(attachment_name)
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

  # TODO move to model?

  def validate_blob_sizes(*blobs, errors)
    blobs.each do |blob|
      return unless blob && (blob.byte_size > max_file_byte_size)
      # TODO parameterise attachment_name
      attachment_name = "file"
      errors.add(:base, :file_too_large, message: "#{attachment_name} is too big, allowed size is #{max_file_byte_size / 1.megabyte}MB")
    end
  end

  def max_file_byte_size
    # If you want your controller to allow different max size, override this
    100.megabytes
  end
end
