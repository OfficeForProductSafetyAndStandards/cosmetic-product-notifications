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
    file_model = Document.new(blob)

    assert_equal file_model.file, blob
    assert_equal file_model.title, metadata[:title]
    assert_equal file_model.description, metadata[:description]
    assert_equal file_model.document_type, metadata[:document_type]
    assert_equal file_model.filename, filename
  end

  test "Document fields are initialised correctly for nil" do
    file_model = Document.new(nil)

    assert_nil file_model.file
    assert_nil file_model.title
    assert_nil file_model.description
    assert_nil file_model.document_type
    assert_nil file_model.filename
  end

  test "Document methods work with nil blob" do
    file_model = Document.new(nil)

    file_model.validate
    file_model.update_file({})
    file_model.purge_file
    file_model.attach_blob_to_list(Investigation::Allegation.new.documents)
    file_model.attach_blob_to_attachment_slot(Correspondence::Meeting.new.transcript)
    file_model.detach_blob_from_list(Investigation::Allegation.new.documents)
  end

  test "Document methods work with a blob" do
    metadata = { title: "title", description: "description", document_type: ".png" }
    filename = "testImage.png"

    blob = create_file_blob(filename, metadata)
    file_model = Document.new(blob)
    file_model.validate
    file_model.update_file({ title: "new title" })
    assert_equal blob.metadata[:title], "new title"
    assert_equal file_model.title, "new title"

    investigation = Investigation::Allegation.create(description: "description")
    file_model.attach_blob_to_list(investigation.documents)
    assert_includes investigation.documents.map { |attachment| attachment.blob }, blob

    file_model.detach_blob_from_list(investigation.documents)
    investigation = Investigation.find_by(description: "description")
    assert_not_includes investigation.documents.map { |attachment| attachment.blob }, blob

    meeting = Correspondence::Meeting.new
    file_model.attach_blob_to_attachment_slot(meeting.transcript)
    assert_equal meeting.transcript.blob, blob
  end

  def create_file_blob(filename = "testImage.png", metadata = nil)
    file = File.open(Rails.root.join("test/fixtures/files/#{filename}"))
    ActiveStorage::Blob.create_after_upload!(io: file, filename: filename, metadata: metadata)
  end
end
