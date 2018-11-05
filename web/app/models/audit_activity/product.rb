class AuditActivity::Product < AuditActivity::Base
  belongs_to :product

  private_class_method def self.from(product, investigation)
    self.create(
      body: product.description,
      source: UserSource.new(user: current_user),
      investigation: investigation,
      title: product.name,
      product: product
    )
  end
end
