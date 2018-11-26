class InvestigationBusiness < ApplicationRecord
  belongs_to :investigation
  belongs_to :business
  # TODO MSPSDS-687 Give these relationships a way to be set
  enum relationship: %i[manufacturer distributor importer]

  default_scope { order('created_at') }
end
