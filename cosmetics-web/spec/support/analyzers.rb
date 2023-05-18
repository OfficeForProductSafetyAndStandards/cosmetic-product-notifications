RSpec.shared_context "without default file analyzers", shared_context: :metadata do
  let(:default_analyzers) { Rails.application.config.active_storage.analyzers.dup }
  let(:default_document_analyzers) { Rails.application.config.document_analyzers.dup }

  before do
    default_analyzers.each { |analyzer| Rails.application.config.active_storage.analyzers.delete(analyzer) }
    default_document_analyzers.each { |analyzer| Rails.application.config.document_analyzers.delete(analyzer) }
  end

  after do
    default_analyzers.each { |analyzer| Rails.application.config.active_storage.analyzers.append(analyzer) }
    default_document_analyzers.each { |analyzer| Rails.application.config.document_analyzers.append(analyzer) }
  end
end

RSpec.configure do |rspec|
  rspec.include_context "without default file analyzers", without_default_file_analyzers: true
end

RSpec.shared_context "with AWS S3 returning a 404 error", shared_context: :metadata do
  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(AntiVirusAnalyzer).to receive(:download_blob_to_tempfile).and_raise(Aws::S3::Errors::NotFound.new("test", "test"))
    # rubocop:enable RSpec/AnyInstance
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with AWS S3 returning a 404 error", with_stubbed_s3_returning_not_found: true
end
