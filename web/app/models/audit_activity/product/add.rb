class AuditActivity::Product::Add < AuditActivity::Product::Base
  def self.from(product, investigation)
    title = product.name
    super(product, investigation, title)
  end

  def subtitle_slug
    "Product added"
  end
end
