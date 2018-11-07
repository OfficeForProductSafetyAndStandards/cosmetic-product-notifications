class AuditActivity::Product::Add < AuditActivity::Product::Base
  def self.from(product, investigation)
    super(product, investigation)
  end

  def subtitle_slug
    "Product added"
  end
end
