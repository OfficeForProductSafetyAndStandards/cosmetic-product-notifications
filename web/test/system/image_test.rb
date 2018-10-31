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

  def attach_file_and_upload
    attach_file("Browse for file", Rails.root + "test/fixtures/files/testImage.png")
    click_on "Upload"
  end
end
