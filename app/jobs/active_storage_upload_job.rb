class ActiveStorageUploadJob < ApplicationJob
  def perform
    generate_local_file
    upload_file
    delete_local_file
    delete_previous_uploads
  end

  def self.file_path
    Rails.root.join("tmp/#{file_name}")
  end

  # Abstract methods.
  # Need to be defined in subclasses.

  def self.file_name
    raise NotImplementedError, "Subclasses must define `file_name`."
  end

private

  def upload_file
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(self.class.file_path),
      filename: self.class.file_name,
    )
  end

  def delete_local_file
    File.delete(self.class.file_path) if File.exist?(self.class.file_path)
  end

  def delete_previous_uploads
    uploads = ActiveStorage::Blob.where(filename: self.class.file_name)
                                 .order(created_at: :desc)
    uploads.drop(1).each(&:purge) # Purges all but the 1st (latest created) one.
  end

  # Abstract methods.
  # Need to be defined in subclasses.

  def generate_local_file
    raise NotImplementedError, "Subclasses must define `generate_local_file`."
  end
end
