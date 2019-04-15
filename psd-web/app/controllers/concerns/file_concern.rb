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

  def load_file_attachments(params_name_override = nil)
    attachment_names.map do |name|
      attachment_params = get_attachment_params(name, params_name_override)
      if attachment_params[:file].present?
        file = ActiveStorage::Blob.create_after_upload!(
          io: attachment_params[:file],
          filename: attachment_params[:file].original_filename,
          content_type: attachment_params[:file].content_type,
          metadata: get_attachment_metadata_params_from_attachment_params(attachment_params)
        )
        session[name] = file.id
        file.analyze_later
        file
      elsif session[name].present?
        ActiveStorage::Blob.find_by(id: session[name])
      end
    end
  end

  def get_attachment_params(_attachment_name, params_key = nil)
    params_key ||= file_params_key
    return {} if params[params_key].blank? || params[params_key].blank?

    params.require(params_key).permit(:file, :title, :description, :document_type, :other_type)
  end

  def get_attachment_metadata_params(attachment_name)
    attachment_params = get_attachment_params attachment_name
    return {} if attachment_params.blank?

    get_attachment_metadata_params_from_attachment_params attachment_params
  end

  def get_attachment_metadata_params_from_attachment_params(attachment_params)
    attachment_params
        .except(:file)
        .to_h
        .merge(created_by: User.current.id)
  end

  def check_correct_usage
    raise "file_params_key must be specified in #{self.class}" unless self.class.file_params_key
    raise "attachment_names must be specified in #{self.class}" unless self.class.attachment_names
  end
end
