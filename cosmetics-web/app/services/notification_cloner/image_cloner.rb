require "notification_cloner/attributes"

module NotificationCloner
  class ImageCloner
    def self.clone(old_notification, new_notification)
      Cheatcodes.image_cloner(old_notification)

      old_notification.image_uploads.each do |old_image_upload|
        new_image_upload = ImageUpload.create(notification: new_notification, filename: old_image_upload.filename)
        blob = old_image_upload.file.blob

        blob.open do |file|
          new_image_upload.file.attach(io: file, filename: blob.filename, content_type: blob.content_type)
        end
      end
    end
  end
end
