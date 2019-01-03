class AuditActivity::Product::Destroy < AuditActivity::Product::Base
  def self.from(product, investigation)
    title = "Removed: #{product.name}"
    super(product, investigation, title)
  end

  def subtitle_slug
    "Product removed"
  end
end
