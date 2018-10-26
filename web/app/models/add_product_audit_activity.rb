class AddProductAuditActivity < ProductAuditActivity
  def title
    product.name
  end

  def subtitle_slug
    "Product added"
  end
end
