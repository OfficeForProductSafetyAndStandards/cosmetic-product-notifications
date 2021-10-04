module FileHelpers
  def create_file_blob(filename = "testPdf.pdf", content_type = "application/pdf", metadata = nil)
    @file = File.open(Rails.root.join("spec/fixtures/files/#{filename}"))
    ActiveStorage::Blob.create_and_upload!(io: @file, filename: filename, content_type: content_type, metadata: metadata)
  end

  def close_file
    @file.close if @file.present?
  end

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join("tmp/storage"))
  end
end
