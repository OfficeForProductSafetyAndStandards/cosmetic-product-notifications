class Contact < ApplicationRecord
  default_scope { order(created_at: :asc) }
  belongs_to :business

  has_one :source, as: :sourceable, dependent: :destroy

  def summary
    [
        name,
        job_title,
        phone_number,
        email
    ].reject(&:blank?).join(", ")
  end
end
