class InvestigationProduct < ApplicationRecord
  belongs_to :investigation
  belongs_to :product
  accepts_nested_attributes_for :product, reject_if: :all_blank
end
