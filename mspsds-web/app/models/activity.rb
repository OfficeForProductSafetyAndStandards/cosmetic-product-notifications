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

private

  def pretty_date_stamp
    created_at.strftime('%d %B %Y')
  end

  def self.sanitize_text(text)
    text.gsub(/[*_~]/){|match| "\\#{match}"}
  end

  def self.sanitize_object(object)
    sanitized = object.dup
    object.attributes.each do |attr_name, attr_value|
      sanitized[attr_name] = self.sanitize_text attr_value if attr_value.is_a? String
    end
    sanitized
  end
end
