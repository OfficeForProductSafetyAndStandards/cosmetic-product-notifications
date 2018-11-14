module ActivityManyAttachable
  extend ActiveSupport::Concern

  included do
    has_many_attached :attachments
  end

  module ClassMethods
    def attach_to_activity(activity, attachment)
      activity.attachments.attach attachment.blob
    end
  end
end
