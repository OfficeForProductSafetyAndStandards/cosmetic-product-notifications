class AuditActivity::Product::Destroy < AuditActivity::Product::Base
  def self.from(product, investigation)
    title = "Removed: #{product.name}"
    super(product, investigation, title)
  end

  def subtitle_slug
    "Product removed"
  end

  def email_update_text
    "Product was removed from the #{investigation.case_type} by #{source&.show&.titleize}."
  end
end
