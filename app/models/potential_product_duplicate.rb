class PotentialProductDuplicate < ApplicationRecord
  belongs_to :product
  belongs_to :duplicate_product, class_name: "Product"
end
