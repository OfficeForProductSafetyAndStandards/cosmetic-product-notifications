class RemoveEmptyAttachments < ActiveRecord::Migration[5.2]
  def change
    # Due to imperfect handling of data removal previously we have some attachments pointing at nils
    ActiveStorage::Attachment.where(blob: nil).delete_all
  end
end
