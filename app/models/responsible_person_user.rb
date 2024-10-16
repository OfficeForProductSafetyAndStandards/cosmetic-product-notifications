class ResponsiblePersonUser < ApplicationRecord
  belongs_to :responsible_person
  belongs_to :user

  def name
    user&.name
  end

  def email_address
    user&.email
  end
end
