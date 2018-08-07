class PotentialProductDuplicate < ApplicationRecord
  belongs_to :product
  belongs_to :duplicate_product, class_name: "Product"

  after_create :create_inverse, unless: :inverse?
  after_destroy :destroy_inverses, if: :inverse?

  # The elasticsearch score does not have a hard upper limit
  # These numbers have been decided on using trial and error
  def descriptive_likelihood
    return "Very likely" if score >= 150
    return "Likely" if score >= 120
    return "Possible" if score >= 90
    "Unlikely"
  end

  def create_inverse
    inverse_properties = inverse_options
    inverse_properties[:score] = score
    self.class.create(inverse_properties)
  end

  def destroy_inverses
    inverses.destroy_all
  end

  def inverse?
    self.class.exists?(inverse_options)
  end

  def inverses
    self.class.where(inverse_options)
  end

  def inverse_options
    { duplicate_product_id: product_id, product_id: duplicate_product_id }
  end
end
