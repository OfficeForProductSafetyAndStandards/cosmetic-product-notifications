require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  describe "Adding and removing product label images" do
    before do
      visit "/responsible_persons/#{responsible_person.id}/notifications"

      click_on "Create a new product notification"
      click_on "Create the product"
      answer_product_name_with "Product"
      answer_do_you_want_to_give_an_internal_reference_with "No"
      answer_is_product_for_under_threes_with "No"
      answer_does_product_contains_nanomaterials_with "No"
      answer_is_product_multi_item_kit_with "No, this is a single product"
    end

    scenario "attempting to progress without uploading a label image" do
      expect(page).to have_h1("Upload an image of the product label")
      click_button "Save and upload another image"
      expect(page).to have_h1("Upload an image of the product label")
      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Select an image", href: "#image_upload")

      click_button "Save and continue"
      expect(page).to have_h1("Upload an image of the product label")
      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Select an image", href: "#image_upload")
    end

    scenario "attaching a single image" do
      expect(page).to have_h1("Upload an image of the product label")
      page.attach_file "spec/fixtures/files/testImage.png"
      click_button "Save and upload another image"
      expect_product_label_images(["testImage.png"])

      click_button "Save and continue"
      expect_task_has_been_completed_page
    end

    scenario "adding multiple images with a single upload" do
      expect(page).to have_h1("Upload an image of the product label")
      page.attach_file ["spec/fixtures/files/testImage.png", "spec/fixtures/files/testLabelImage.jpg"]
      click_button "Save and upload another image"
      expect_product_label_images(["testImage.png", "testLabelImage.jpg"])

      click_button "Save and continue"
      expect_task_has_been_completed_page
    end

    scenario "adding multiple images one by one" do
      expect(page).to have_h1("Upload an image of the product label")
      page.attach_file ["spec/fixtures/files/testImage.png"]
      click_button "Save and upload another image"
      expect_product_label_images(["testImage.png"])

      click_button "Save and upload another image"
      expect(page).to have_h1("Upload an image of the product label")

      page.attach_file "spec/fixtures/files/testLabelImage.jpg"
      click_button "Save and upload another image"
      expect_product_label_images(["testImage.png", "testLabelImage.jpg"])

      click_button "Save and continue"
      expect_task_has_been_completed_page
    end

    scenario "removing one of the images after upload" do
      expect(page).to have_h1("Upload an image of the product label")
      page.attach_file ["spec/fixtures/files/testImage.png", "spec/fixtures/files/testLabelImage.jpg"]
      click_button "Save and upload another image"
      expect_product_label_images(["testImage.png", "testLabelImage.jpg"])

      click_button("Remove", match: :first)
      expect_product_label_images(["testImage.png"])

      click_button "Save and continue"
      expect_task_has_been_completed_page
    end
  end
end
