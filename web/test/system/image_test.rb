require "application_system_test_case"

class ImageTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit new_investigation_image_path(investigations(:one))
  end

  teardown do
    logout
  end

  test "First step should be file upload" do
    assert_text("Browse for file")
  end

  test "Second step should be details" do
    attach_file_and_upload
    assert_text "Enter image details"
  end

  test "details should validate title" do
    attach_file_and_upload
    click_on "Save"
    assert_text "prohibited this case from being saved:"
  end

  test "details should be valid if title exists" do
    attach_file_and_upload
    fill_in "Image title", with: "Beautiful picture"
    click_on "Save"
    assert_text "There are no products attached to this case"
  end

  test "image data should be in attachments" do
    attach_file_and_upload
    fill_in "Image title", with: "Beautiful picture"
    click_on "Save"
    click_on "Attachments"
    assert_text "Beautiful picture"
  end

  test "should not attach a file without actually saving it" do
    attach_file_and_upload
    visit investigation_path(investigations(:one))
    click_on "Attachments"
    assert_no_text "View full image"
  end

  test "should allow to edit file title" do
    get_to_edit
    fill_in "Image title", with: "Ugly picture"
    click_on "Save"
    click_on "Attachments"
    assert_text "Ugly picture"
  end

  test "should allow to delete a picture" do
    get_to_edit
    click_on "Delete"
    click_on "Attachments"
    assert_no_text "Beautiful picture"
  end

  def get_to_edit
    attach_file_and_upload
    fill_in "Image title", with: "Beautiful picture"
    click_on "Save"
    click_on "Attachments"
    click_on "Edit image details or delete"
    assert_text "Edit image details"
  end

  def attach_file_and_upload
    attach_file("Browse for file", Rails.root + "test/fixtures/files/testImage.png")
    click_on "Upload"
  end
end
