require "application_system_test_case"

class DocumentTest < ApplicationSystemTestCase
  include UrlHelper
  setup do
    mock_out_keycloak_and_notify
    accept_declaration
    visit new_document_flow_path(investigations(:no_products))
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "First step should be file upload" do
    assert_text("Browse for file")
  end

  test "First step should require file attachment" do
    click_on "Upload"
    assert_text "There is a problem"
  end

  test "Second step should be details" do
    attach_file_and_upload
    assert_text "Document details"
  end

  test "details should validate title" do
    attach_file_and_upload
    click_on "Save attachment"
    assert_text "There is a problem"
  end

  test "details should be valid if title exists" do
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    click_on "Save attachment"
    assert_current_path(/cases\/\d+/)
  end

  test "Document data should be in attachments" do
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    click_on "Save attachment"
    click_on "Attachments"
    assert_text "long document"
  end

  test "should not attach a file without actually saving it" do
    attach_file_and_upload
    visit investigation_path(investigations(:one))
    click_on "Attachments"
    assert_no_text "View PDF document"
  end

  test "should allow to edit file title" do
    get_to_edit
    fill_in "Document title", with: "short document"
    click_on "Update attachment"
    click_on "Attachments"
    assert_text "short document"
  end

  test "should allow to edit file description" do
    get_to_edit
    fill_in "Description", with: "This is a long document"
    click_on "Update attachment"
    click_on "Attachments"
    assert_text "This is a long document"
  end

  test "should allow to delete a document" do
    get_to_attachments
    click_on "Remove document"
    click_on "Delete attachment"
    click_on "Attachments"
    assert_no_text "long document"
  end

  test "should create activity when adding a document" do
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    fill_in "Description", with: "description"
    click_on "Save attachment"
    click_on "Activity"
    assert_text "Document added"
  end

  test "should create activity when editing a document" do
    get_to_edit
    fill_in "Description", with: "This is a long document"
    click_on "Update attachment"
    click_on "Activity"
    assert_text "Document details updated"
  end

  test "should create activity when removing a document" do
    get_to_attachments
    click_on "Remove document"
    click_on "Delete attachment"
    click_on "Activity"
    assert_text "Document deleted"
  end

  def get_to_edit
    get_to_attachments
    click_on "Edit document"
    assert_text "Edit document details"
  end

  def get_to_attachments
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    fill_in "Description", with: "description"
    click_on "Save attachment"
    click_on "Attachments"
  end

  def attach_file_and_upload
    attach_file("Browse for file", file_fixture("old_risk_assessment.txt"))
    click_on "Upload"
  end
end
