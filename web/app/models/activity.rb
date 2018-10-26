class Activity < ApplicationRecord
  belongs_to :investigation

  has_one :source, as: :sourceable, dependent: :destroy

  def title
    nil
  end

  def subtitle_slug
    nil
  end
end
