# TODO MSPSDS-266: Remove this model and migrate imported images to ActiveStorage attachments
class RapexImage < ApplicationRecord
  belongs_to :product

  has_paper_trail
end
