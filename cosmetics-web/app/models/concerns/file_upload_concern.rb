module FileUploadConcern
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :attachment_name, :allowed_types, :max_file_size, :check_file_exists

  private

    def set_attachment_name(name)
      @attachment_name = name
    end

    def set_allowed_types(types)
      @allowed_types = types
    end

    def set_max_file_size(size)
      @max_file_size = size
    end

    def set_check_file_exists(check)
      @check_file_exists = check
    end

    # This is here because it is used in an `included` block below
    def validate_on
      # `%i[create update]` is the Rails default
      @_validate_on || %i[create update]
    end
  end

  def attachment_name
    check_correct_usage
    self.class.attachment_name
  end

  def allowed_types
    check_correct_usage
    self.class.allowed_types
  end

  def max_file_size
    check_correct_usage
    self.class.max_file_size
  end

  def check_file_exists
    self.class.check_file_exists || false
  end

  def check_correct_usage
    raise "attachment_name must be specified in #{self.class}" unless self.class.attachment_name
    raise "allowed_types must be specified in #{self.class}" unless self.class.allowed_types
    raise "max_file_size must be specified in #{self.class}" unless self.class.max_file_size
  end

  included do
    validate :attached_file_exists?, on: validate_on
    validate :attached_file_is_correct_type?, on: validate_on
    validate :attached_file_is_within_allowed_size?, on: validate_on
  end

private

  def attached_file_exists?
    return unless check_file_exists

    attached = send(attachment_name).attached?
    unless attached
      errors.add attachment_name, "File must be uploaded"
    end
  end

  def attached_file_is_correct_type?
    attachment = send(attachment_name).attachment
    unless attachment.nil? || allowed_types.include?(send(attachment_name).blob.content_type)
      errors.add attachment_name, "must be one of #{allowed_types.join(', ')}"
    end
  end

  def attached_file_is_within_allowed_size?
    attachment = send(attachment_name).attachment
    unless attachment.nil? || send(attachment_name).blob.byte_size <= max_file_size
      errors.add attachment_name, "must be smaller than #{max_file_size / 1.megabyte}MB"
    end
  end
end
