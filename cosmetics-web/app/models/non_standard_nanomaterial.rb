class NonStandardNanomaterial < ApplicationRecord
  belongs_to :responsible_person

  validates :iupac_name, presence: true, on: :add_iupac_name
end
