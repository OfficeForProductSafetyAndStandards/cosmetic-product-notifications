class DestroyImageAuditActivity < ImageAuditActivity
  def self.from(image, investigation)
    title = "Deleted: #{image.metadata[:title]}"
    super(image, investigation, title)
  end

  def subtitle_slug
    "Image deleted"
  end
end
