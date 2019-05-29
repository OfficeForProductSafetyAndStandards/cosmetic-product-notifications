class Cmr < ApplicationRecord
  belongs_to :component

  def display_name
    [name, cas_number, ec_number].reject(&:blank?).join(', ')
  end
end
