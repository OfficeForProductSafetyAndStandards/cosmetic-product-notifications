class AuditActivity::Image::Base < AuditActivity::Base
  has_one_attached :image

  private_class_method def self.from(image, investigation, title)
    activity = self.create(
      body: image.metadata[:description],
        source: UserSource.new(user: current_user),
        investigation: investigation,
        title: title
    )
    activity.image.attach image.blob
  end

  def attached_image?
    self.image.attached?
  end
end
