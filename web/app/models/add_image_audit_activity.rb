class AddImageAuditActivity < ImageAuditActivity
  def subtitle_slug
    "Image added"
  end

  def title
    image.attachment.metadata[:title] || "Untitled image"
  end
end
