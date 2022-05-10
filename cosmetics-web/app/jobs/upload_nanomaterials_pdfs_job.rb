require "zip"
require "fileutils"

class UploadNanomaterialsPdfsJob < ApplicationJob
  FILE_NAME = "NanomaterialsPDFs.zip".freeze
  FILE_PATH = Rails.root.join("tmp/#{FILE_NAME}").freeze
  TMP_DIR   = "tmp/nanomaterials_pdfs".freeze

  def perform
    download_pdfs
    generate_zip_file
    upload_to_cloud_storage
    delete_tmp_files
    delete_previous_uploads
  end

private

  def download_pdfs
    FileUtils.mkdir_p(TMP_DIR)
    NanomaterialNotification.find_each do |nano|
      nano.file.open(tmpdir: "tmp") do |file|
        FileUtils.cp(file, "#{TMP_DIR}/#{nano.id}.pdf")
      end
    end
  end

  def generate_zip_file
    input_filenames = Dir.children(TMP_DIR)
    ::Zip::File.open(FILE_PATH, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(File.basename(filename), "#{TMP_DIR}/#{filename}")
      end
    end
  end

  def upload_to_cloud_storage
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(FILE_PATH),
      filename: FILE_NAME,
    )
  end

  def delete_tmp_files
    FileUtils.remove_dir(TMP_DIR) if Dir.exist?(TMP_DIR)
    File.delete(FILE_PATH) if File.exist?(FILE_PATH)
  end

  def delete_previous_uploads
    uploads = ActiveStorage::Blob.where(filename: FILE_NAME).order(created_at: :desc)
    uploads.drop(1).each(&:purge) # Purges all but the 1st (latest created) one.
  end
end
