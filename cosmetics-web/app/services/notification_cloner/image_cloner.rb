module NotificationCloner
  class ImageCloner
    def self.clone(old_notification, new_notification)
      # Useful way for tester to make sure it works as expected
      # Cheatcodes.image_cloner(old_notification)

      old_notification.image_uploads.each do |old_image_upload|
        new_image_upload = ImageUpload.create(notification: new_notification, filename: old_image_upload.filename)
        blob = old_image_upload.file.blob

        begin
          blob.open do |file|
            new_image_upload.file.attach(io: file, filename: blob.filename, content_type: blob.content_type)
          end
        rescue ActiveStorage::FileNotFoundError
          new_image_upload.delete
          raise
        end
      end
    end
  end
end
