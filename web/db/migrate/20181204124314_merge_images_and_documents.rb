class MergeImagesAndDocuments < ActiveRecord::Migration[5.2]
  def change
    Activity.where(type: "AuditActivity::Image::Add").delete_all
    Activity.where(type: "AuditActivity::Image::Update").delete_all
    Activity.where(type: "AuditActivity::Image::Destroy").delete_all
    ActiveStorage::Attachment.where(blob: nil).delete_all
  end
end
