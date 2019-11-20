class NanomaterialNotification < ApplicationRecord
  class AlreadySubmittedError < StandardError; end

  belongs_to :responsible_person

  validates :iupac_name, presence: true, on: :add_iupac_name

  validates :eu_notified, inclusion: { in: [true, false] }, on: :eu_notification

  validates :notified_to_eu_on, presence: true, on: :eu_notification, if: :eu_notified?
  validate :eu_notification_date_must_be_pre_brexit, on: :eu_notification, if: :eu_notified?

  validate :eu_notification_date_is_nil, on: :eu_notification, if: :eu_not_notified?

  validate :file_attached, on: :upload_file

  has_one_attached :file


  def submit!
    raise AlreadySubmittedError, "Nanomaterial previously notified, on #{submitted_at}" if submitted?

    self.submitted_at = DateTime.now
    save!
  end

  def submitted?
    submitted_at != nil
  end

private

  def eu_notification_date_must_be_pre_brexit
    if notified_to_eu_on && notified_to_eu_on > EU_EXIT_DATE
      errors.add(:notified_to_eu_on, "Enter a date before Brexit")
    end
  end

  def eu_notification_date_is_nil
    if notified_to_eu_on != nil
      errors.add(:notified_to_eu_on, I18n.t(:date_specified_but_eu_not_notified, scope: %i[activerecord errors models nanomaterial_notification attributes notified_to_eu_on]))
    end
  end

  def file_attached
    if !file.attached?
      errors.add(:file, I18n.t(:missing, scope: %i[activerecord errors models nanomaterial_notification attributes file]))
    end
  end

  def eu_not_notified?
    eu_notified == false
  end
end
