class Activity < ApplicationRecord
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  def attached_image?
    nil
  end

  def build_subtitle
    p source
    "#{subtitle_slug} by #{source.show}, #{created_at.strftime('%d %B %Y')}"
  end
end
