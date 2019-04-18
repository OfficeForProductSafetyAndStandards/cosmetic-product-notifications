require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "Document can be initialised only with nil or a bob" do
    blob = create_file_blob
    attachment = ActiveStorage::Attachment.new
    Document.new(nil)
    Document.new(blob)

    begin
      Document.new(attachment)
    rescue StandardError => e
      assert_equal e.message, "Document can only be initialized with an active storage blob or nil"
    end
  end

  test "Document fields are initialised correctly for a blob" do
    metadata = { title: "title", description: "description", document_type: ".png" }
    filename = "testImage.png"

    blob = create_file_blob(filename, metadata)
    document_model = Document.new(blob)

    assert_equal document_model.file, blob
    assert_equal document_model.title, metadata[:title]
    assert_equal document_model.description, metadata[:description]
    assert_equal document_model.document_type, metadata[:document_type]
    assert_equal document_model.filename, filename
  end

  test "Document fields are initialised correctly for nil" do
    document_model = Document.new(nil)

    assert_nil document_model.file
    assert_nil document_model.title
    assert_nil document_model.description
    assert_nil document_model.document_type
    assert_nil document_model.filename
  end

  test "Document methods work with nil blob" do
    document_model = Document.new(nil)

    document_model.validate
    document_model.update_file({})
    document_model.purge_file
    document_model.attach_blob_to_list(Investigation::Allegation.new.documents)
    document_model.attach_blob_to_attachment_slot(Correspondence::Meeting.new.transcript)
    document_model.detach_blob_from_list(Investigation::Allegation.new.documents)
  end

  test "Document methods work with a blob" do
    metadata = { title: "title", description: "description", document_type: ".png" }
    filename = "testImage.png"

    blob = create_file_blob(filename, metadata)
    document_model = Document.new(blob)
    document_model.validate
    document_model.update_file({ title: "new title" })
    assert_equal blob.metadata[:title], "new title"
    assert_equal document_model.title, "new title"

    investigation = Investigation::Allegation.create(description: "description")
    document_model.attach_blob_to_list(investigation.documents)
    assert_includes investigation.documents.map { |attachment| attachment.blob }, blob

    document_model.detach_blob_from_list(investigation.documents)
    investigation = Investigation.find_by(description: "description")
    assert_not_includes investigation.documents.map { |attachment| attachment.blob }, blob

    meeting = Correspondence::Meeting.new
    document_model.attach_blob_to_attachment_slot(meeting.transcript)
    assert_equal meeting.transcript.blob, blob
  end

  def create_file_blob(filename = "testImage.png", metadata = nil)
    file = File.open(Rails.root.join("test/fixtures/files/#{filename}"))
    ActiveStorage::Blob.create_after_upload!(io: file, filename: filename, metadata: metadata)
  end
end
