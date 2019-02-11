class Activity < ApplicationRecord
  class << self
    include UserService
  end

  belongs_to :investigation, touch: true

  has_one :source, as: :sourceable, dependent: :destroy

  after_save :notify_relevant_users

  def attached_image?
    nil
  end

  def has_attachment?
    false
  end

  def attachments
    {}
  end

  def subtitle
    "#{subtitle_slug} by #{source.show}, #{pretty_date_stamp}"
  end

  def subtitle_slug; end

  def search_index;  end

  def self.sanitize_text(text)
    return text.to_s.strip.gsub(/[*_~]/) { |match| "\\#{match}" } if text
  end

  def sensitive_body?
    false
  end

  def notify_relevant_users
    users_to_notify.each do |user|
      NotifyMailer.updated_investigation(investigation.id, user.full_name, user.email, email_update_text).deliver_later
    end
  end

  def users_to_notify
    return [investigation.assignee] if investigation.assignee.is_a? User
    return [] if source&.user&.teams&.include? investigation.assignee

    investigation.assignee&.users || []
  end

  def email_update_text; end

private

  def pretty_date_stamp
    created_at.strftime('%d %B %Y')
  end
end
