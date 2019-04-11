class RemoveBusinessAttachments < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.where(record_type: "Business").delete_all
  end
end
