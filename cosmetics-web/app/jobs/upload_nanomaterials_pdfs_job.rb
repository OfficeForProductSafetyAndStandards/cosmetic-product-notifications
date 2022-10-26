require "zip"
require "fileutils"

class UploadNanomaterialsPdfsJob < ActiveStorageUploadJob
  FILE_NAME = "NanomaterialsPDFs.zip".freeze
  TMP_DIR   = "tmp/nanomaterials_pdfs".freeze

  def self.file_name
    self::FILE_NAME
  end

private

  def generate_local_file
    download_pdfs
    generate_zip
    delete_downloaded_pdfs
  end

  def download_pdfs
    FileUtils.mkdir_p(TMP_DIR)
    NanomaterialNotification.find_each do |nano|
      nano.file.open(tmpdir: "tmp") do |file|
        FileUtils.cp(file, "#{TMP_DIR}/#{nano.ukn}.pdf")
      end
    end
  end

  def generate_zip
    input_filenames = Dir.children(TMP_DIR)
    ::Zip::File.open(self.class.file_path, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(File.basename(filename), "#{TMP_DIR}/#{filename}")
      end
    end
  end

  def delete_downloaded_pdfs
    FileUtils.remove_dir(TMP_DIR) if Dir.exist?(TMP_DIR)
  end
end
