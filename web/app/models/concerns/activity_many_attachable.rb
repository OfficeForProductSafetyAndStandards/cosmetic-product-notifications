module ActivityManyAttachable
  extend ActiveSupport::Concern

  included do
    has_many_attached :attachments
  end

  module ClassMethods
    def attach_to_activity(activity, attachment, metadata_opts = {})
      metadata_opts.each { |k, v| attachment.blob.metadata[k] = v }
      activity.attachments.attach attachment.blob
    end
  end
end
