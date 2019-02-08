class NotificationFile < ApplicationRecord
  has_one_attached :uploaded_file
  belongs_to :responsible_person
  belongs_to :user
end
