class NotificationFile < ApplicationRecord
  has_one_attached :uploaded_file
end
