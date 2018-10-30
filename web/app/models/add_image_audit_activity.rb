class AddImageAuditActivity < ImageAuditActivity
  def self.from(image, investigation)
    title = image.metadata[:title] || "Untitled image"
    super(image, investigation, title)
  end

  def subtitle_slug
    "Image added"
  end
end
