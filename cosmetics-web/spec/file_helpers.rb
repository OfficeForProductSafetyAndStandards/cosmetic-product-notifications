module FileHelpers
  def mock_antivirus_api
    response = double
    allow(response).to receive(:body).and_return({ safe: true }.to_json)
    allow(RestClient::Request).to receive(:execute).with(hash_including(url: ENV["ANTIVIRUS_URL"])).and_return(response)
  end

  def unmock_antivirus_api
    allow(RestClient::Request).to receive(:execute).with(hash_including(url: ENV["ANTIVIRUS_URL"])).and_call_original
  end

  def create_file_blob(filename = "testExportFile.zip", content_type = "application/zip", metadata = nil)
    file = File.open(Rails.root.join("spec", "fixtures", filename))
    ActiveStorage::Blob.create_after_upload!(io: file, filename: filename, content_type: content_type, metadata: metadata)
  end

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end
