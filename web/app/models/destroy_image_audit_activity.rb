class DestroyImageAuditActivity < ImageAuditActivity
  def self.from(image, investigation)
    title = "Deleted: #{image.metadata[:title]}"
    activity = self.create(
        description: image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.image.attach image.blob
  end

  def subtitle_slug
    "Image deleted"
  end
end
