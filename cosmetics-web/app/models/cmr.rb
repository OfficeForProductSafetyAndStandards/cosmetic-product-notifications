class Cmr < ApplicationRecord
  belongs_to :component

  def display_name
    [name, ec_number, cas_number].reject(&:blank?).join(', ')
  end
end
