class ImageAuditActivity < AuditActivity
  has_one_attached :image

  def attached_image?
    self.image.attached?
  end
end
