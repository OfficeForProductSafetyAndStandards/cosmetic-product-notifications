class DocumentAuditActivity < AuditActivity
  has_one_attached :document

  def attached_document?
    self.document.attached?
  end
end
