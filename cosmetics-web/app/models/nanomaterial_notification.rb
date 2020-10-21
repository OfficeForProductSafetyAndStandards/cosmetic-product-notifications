class NanomaterialNotification < ApplicationRecord
  class AlreadySubmittedError < StandardError; end

  belongs_to :responsible_person

  validates :name, presence: true, on: :add_name

  validates :eu_notified, inclusion: { in: [true, false] }, on: :eu_notification

  validates :notified_to_eu_on, presence: true, on: :eu_notification, if: :eu_notified?
  validate :eu_notification_date_must_be_pre_brexit, on: :eu_notification, if: :eu_notified?

  validate :eu_notification_date_is_nil, on: :eu_notification, if: :eu_not_notified?

  validate :eu_notification_date_is_real

  validate :pdf_file_attached, on: :upload_file

  has_one_attached :file

  # Expects either a date object, or a hash containing
  # year, month and day, for example:
  #
  # {year: "2019", month: "01", day: "20"}
  def notified_to_eu_on=(notified_to_eu_on)
    return if notified_to_eu_on.nil?

    if notified_to_eu_on.is_a?(Date)
      date = notified_to_eu_on
    elsif notified_to_eu_on[:year].present? && notified_to_eu_on[:month].present? && notified_to_eu_on[:day].present?
      begin
        date = Date.new(notified_to_eu_on[:year].to_i, notified_to_eu_on[:month].to_i, notified_to_eu_on[:day].to_i)
      rescue ArgumentError
        date = OpenStruct.new(year: notified_to_eu_on[:year], month: notified_to_eu_on[:month], day: notified_to_eu_on[:day])
      end
    elsif notified_to_eu_on[:year].present? || notified_to_eu_on[:month].present? || notified_to_eu_on[:day].present?
      date = OpenStruct.new(year: notified_to_eu_on[:year], month: notified_to_eu_on[:month], day: notified_to_eu_on[:day])
    else
      date = nil
    end

    self[:notified_to_eu_on] = date
  end

  def submit!
    raise AlreadySubmittedError, "Nanomaterial previously notified, on #{submitted_at}" if submitted?

    self.submitted_at = DateTime.now
    save!
  end

  def submitted?
    submitted_at != nil
  end

  # Checks whether all validations have passed, but without adding error messages.
  # Used to determine whether user is changing an answer from Check your answers or not.
  def submittable?
    submittable = valid?(%i[add_name eu_notification upload_file])
    errors.clear
    submittable
  end

  def can_be_made_available_on_uk_market_from
    return nil unless submitted?

    availability_date =
      if eu_notified?
        if notified_to_eu_on <= (EU_EXIT_DATE - 6.months)
          notified_to_eu_on + 6.months
        else
          notified_to_eu_on + 7.months
        end
      else
        submitted_at.in_time_zone("London") + 6.months
      end

    availability_date.at_midnight
  end

  def can_be_made_available_on_uk_market?
    can_be_made_available_on_uk_market_from <= Time.zone.now
  end

private

  def eu_notification_date_must_be_pre_brexit
    if notified_to_eu_on && notified_to_eu_on.is_a?(Date) && notified_to_eu_on > EU_EXIT_DATE
      errors.add(:notified_to_eu_on, I18n.t(:post_brexit_date_given, scope: %i[activerecord errors models nanomaterial_notification attributes notified_to_eu_on]))
    end
  end

  def eu_notification_date_is_real
    if notified_to_eu_on && !notified_to_eu_on.is_a?(Date)

      translation_scope = %i[activerecord errors models nanomaterial_notification attributes notified_to_eu_on]

      if notified_to_eu_on.day.blank? || notified_to_eu_on.month.blank? || notified_to_eu_on.year.blank?

        missing_date_parts = []
        missing_date_parts << "day" if notified_to_eu_on.day.blank?
        missing_date_parts << "month" if notified_to_eu_on.month.blank?
        missing_date_parts << "year" if notified_to_eu_on.year.blank?

        error_message = if missing_date_parts.size == 3
                          I18n.t(:blank, scope: translation_scope)
                        else
                          I18n.t(:date_incomplete, missing_date_parts: missing_date_parts.to_sentence, scope: translation_scope)
                        end

      else
        error_message = I18n.t(:not_a_real_date, scope: translation_scope)
      end

      errors.add(:notified_to_eu_on, error_message)
    end
  end

  def eu_notification_date_is_nil
    unless notified_to_eu_on.nil?
      errors.add(:notified_to_eu_on, I18n.t(:date_specified_but_eu_not_notified, scope: %i[activerecord errors models nanomaterial_notification attributes notified_to_eu_on]))
    end
  end

  def pdf_file_attached
    if !file.attached?
      errors.add(:file, I18n.t(:missing, scope: %i[activerecord errors models nanomaterial_notification attributes file]))
    elsif file.blob.content_type != "application/pdf"
      file.purge
      errors.add(:file, I18n.t(:must_be_a_pdf, scope: %i[activerecord errors models nanomaterial_notification attributes file]))
    end
  end

  def eu_not_notified?
    eu_notified == false
  end
end
