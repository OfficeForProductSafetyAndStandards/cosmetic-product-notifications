require "zip"
require "fileutils"

class UploadNanomaterialsPdfsAbstractJob < ActiveStorageUploadJob
  def self.file_name
    self::FILE_NAME # FILE_NAME constant needs to be defined in subclasses
  end

  def self.tmp_dir
    self::TMP_DIR # TMP_DIR constant needs to be defined in subclasses
  end

private

  def generate_local_file
    download_pdfs
    generate_zip
    delete_downloaded_pdfs
  end

  def download_pdfs
    FileUtils.mkdir_p(self.class.tmp_dir)
    nanomaterial_notifications_to_download.find_each do |nano|
      nano.file.open(tmpdir: "tmp") do |file|
        FileUtils.cp(file, "#{self.class.tmp_dir}/#{nano.ukn}.pdf")
      end
    rescue ActiveStorage::FileNotFoundError
      next
    end
  end

  def nanomaterial_notifications_to_download
    raise ArgumentError, "Abstract definition. Implement this method in a subclass"
  end

  def generate_zip
    input_filenames = Dir.children(self.class.tmp_dir)
    ::Zip::File.open(self.class.file_path, create: true) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(File.basename(filename), "#{self.class.tmp_dir}/#{filename}")
      end
    end
  end

  def delete_downloaded_pdfs
    FileUtils.remove_dir(self.class.tmp_dir) if Dir.exist?(self.class.tmp_dir)
  end
end
