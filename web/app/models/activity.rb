class Activity < ApplicationRecord
  class << self
    include UserService
  end

  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  def attached_image?
    nil
  end

  def subtitle
    "#{subtitle_slug} by #{source.show}, #{pretty_date_stamp}"
  end

  def subtitle_slug; end

private

  def pretty_date_stamp
    created_at.strftime('%d %B %Y')
  end
end
