class AuditActivity::Image < AuditActivity
  has_one_attached :image

  private_class_method def self.from(image, investigation, title)
                         activity = self.create(
                             description: image.metadata[:description],
                             source: UserSource.new(user: current_user),
                             investigation: investigation,
                             title: title)
                         activity.image.attach image.blob
                       end

  def attached_image?
    self.image.attached?
  end
end
