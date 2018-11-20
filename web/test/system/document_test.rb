require "application_system_test_case"

class DocumentTest < ApplicationSystemTestCase
  include UrlHelper
  setup do
    sign_in_as_user
    visit new_document_flow_path(investigations(:no_products))
  end

  teardown do
    logout
  end

  test "First step should be file upload" do
    assert_text("Browse for file")
  end

  test "First step should require file attachment" do
    click_on "Upload"
    assert_text "prohibited this item from being saved:"
  end

  test "Second step should be details" do
    attach_file_and_upload
    assert_text "Enter document details"
  end

  test "details should validate title" do
    attach_file_and_upload
    click_on "Save"
    assert_text "prohibited this item from being saved:"
  end

  test "details should be valid if title exists" do
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    click_on "Save"
    assert_text "There are no products attached to this case"
  end

  test "Document data should be in attachments" do
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    click_on "Save"
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
    click_on "Save"
    click_on "Attachments"
    assert_text "short document"
  end

  test "should allow to edit file description" do
    get_to_edit
    fill_in "Description", with: "This is a long document"
    click_on "Save"
    click_on "Attachments"
    assert_text "This is a long document"
  end

  test "should allow to delete a document" do
    get_to_edit
    click_on "Delete"
    click_on "Attachments"
    assert_no_text "long document"
  end

  def get_to_edit
    attach_file_and_upload
    fill_in "Document title", with: "long document"
    fill_in "Description", with: "description"
    click_on "Save"
    click_on "Attachments"
    click_on "Edit document details or delete"
    assert_text "Edit document details"
  end

  def attach_file_and_upload
    attach_file("Browse for file", Rails.root + "test/fixtures/files/old_risk_assessment.txt")
    click_on "Upload"
  end
end
