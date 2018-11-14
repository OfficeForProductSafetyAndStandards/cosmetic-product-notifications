module ActivityManyAttachable
  extend ActiveSupport::Concern

  included do
    has_many_attached :attachments
  end

  module ClassMethods
    def attach_to_activity(activity, attachment, metadata_opts = {})
      attachments = activity.attachments.attach attachment.blob
      metadata_opts.each { |k, v| attachments.last.blob.metadata[k] = v }
    end
  end
end
