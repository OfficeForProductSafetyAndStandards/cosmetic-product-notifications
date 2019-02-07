class ResponsiblePersonUser < ApplicationRecord
  belongs_to :responsible_person
  belongs_to :user

  def full_name
    user&.full_name
  end

  def email_address
    user&.email
  end
end
