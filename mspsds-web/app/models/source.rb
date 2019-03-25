class Source < ApplicationRecord
  belongs_to :sourceable, polymorphic: true

  def show
    nil
  end

  def created_by
    "Created by #{show}, #{created_at.strftime('%d/%m/%Y')}"
  end

  def current_user_has_gdpr_access?
    true
  end
end
