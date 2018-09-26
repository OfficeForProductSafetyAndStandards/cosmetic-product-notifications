class InvestigationBusiness < ApplicationRecord
  belongs_to :investigation
  belongs_to :business
  accepts_nested_attributes_for :business, reject_if: :all_blank
end
