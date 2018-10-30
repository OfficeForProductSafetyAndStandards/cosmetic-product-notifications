class AddImageAuditActivity < ImageAuditActivity
  def self.from(image, investigation)
    title = image.metadata[:title] || "Untitled image"
    activity = self.create(
        description: image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.image.attach image.blob
  end

  def subtitle_slug
    "Image added"
  end
end
