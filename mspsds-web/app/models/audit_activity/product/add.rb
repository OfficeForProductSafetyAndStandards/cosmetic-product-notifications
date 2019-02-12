class AuditActivity::Product::Add < AuditActivity::Product::Base
  def self.from(product, investigation)
    title = product.name
    super(product, investigation, title)
  end

  def subtitle_slug
    "Product added"
  end

  def email_update_text
    "Product was added to the #{investigation.case_type} by #{source&.show&.titleize}."
  end
end
