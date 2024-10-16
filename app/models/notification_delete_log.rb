class NotificationDeleteLog < ApplicationRecord
  belongs_to :submit_user, optional: true
  belongs_to :responsible_person
end
