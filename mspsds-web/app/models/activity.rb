class Activity < ApplicationRecord
  class << self
    include UserService
  end

  belongs_to :investigation, touch: true

  has_one :source, as: :sourceable, dependent: :destroy

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

  def sensitive_body?; end

private

  def pretty_date_stamp
    created_at.strftime('%d %B %Y')
  end
end
