module ActivityAttachable
  extend ActiveSupport::Concern

  included do
    has_one_attached :attachment
  end

  module ClassMethods
    def attach_to_activity(activity, attachment)
      activity.attachment.attach attachment.blob
    end
  end
end
