module ActivityAttachable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :attachment_names

  private

    def with_attachments(names)
      @attachment_names = names
      @attachment_names.each do |key, _|
        self.class_eval do
          has_one_attached key
        end
      end
    end
  end

  def attachment_names
    klass = self.class
    while klass.respond_to? :attachment_names do
      return klass.attachment_names if klass.attachment_names.present?

      klass = klass.superclass
    end
    {}
  end

  def has_attachment?
    return false if attachment_names.blank?

    attachment_names.any? { |key, _| self.send(key)&.attached? }
  end

  def attachments
    return {} unless has_attachment?

    attachment_names.map { |key, name| [name, self.send(key)] }.to_h
  end

  def add_attachment(attachment, attachment_key = attachment_names.keys.first)
    return unless attachment_key.present? && attachment.present?

    if attachment.blob.present?
      # If a blob is purged by antivirus after upload but before this attachment is created we will get weird errors
      # namely attachment will exist and in case of has_one say something is attached, but that something will be nil
      self.send(attachment_key).attach attachment.blob
    end
  end
end
