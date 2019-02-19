module FileHelpers
  def mock_antivirus
    allow(Clamby).to receive(:safe?).and_return(true)
  end

  def unmock_antivirus
    allow(Clamby).to receive(:safe?).and_call_original
  end

  def create_file_blob(filename: "testExportFile.zip", content_type: "application/zip", metadata: nil)
    ActiveStorage::Blob.create_after_upload! io: fixture_file_upload(filename).open, filename: filename, content_type: content_type, metadata: metadata
  end

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end
