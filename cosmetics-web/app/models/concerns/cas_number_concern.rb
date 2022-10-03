module CasNumberConcern
  extend ActiveSupport::Concern

  included do
    validates_with CasNumberValidator

    before_save :normalise_cas_number
  end

  def normalise_cas_number
    self.cas_number = cas_number.presence&.delete("-")
  end
end
