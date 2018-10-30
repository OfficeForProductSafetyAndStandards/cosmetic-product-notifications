class UpdateImageAuditActivity < ImageAuditActivity
  def self.from(image, investigation, previous_data)
    if image.metadata[:title] != previous_data[:title]
      title = "Updated: #{image.metadata[:title] || "Untitled image"} (was: #{previous_data[:title] || "Untitled image"})"
    elsif image.metadata[:description] != previous_data[:description]
      title = "Updated: Description for #{image.metadata[:title]}"
    end
    activity = self.create(
        description: image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title)
    activity.image.attach image.blob
  end

  def subtitle_slug
    "Image details updated"
  end
end
