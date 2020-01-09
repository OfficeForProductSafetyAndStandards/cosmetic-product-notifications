require "rails_helper"

RSpec.describe "ZIP file upload, pre-Brexit notifications", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  scenario "Using a zip file with a post-Brexit EU notification date", :with_stubbed_antivirus do
    visit new_responsible_person_add_notification_path(responsible_person)

    expect_to_be_on_was_eu_notified_about_products_page
    answer_was_eu_notified_with "Yes"

    expect_to_be_on_do_you_have_the_zip_files_page
    answer_do_you_have_zip_files_with "Yes"

    expect_to_be_on_upload_eu_notification_files_page
    upload_zip_file "testExportFilePostBrexit.zip"

    visit responsible_person_notifications_path(responsible_person)

    expect_to_see_notification_error "You can not upload a product notified in the EU after 31 October 2019. To notify this product, enter its details manually. Click 'Add cosmetic products' to start."
    click_button "Dismiss"

    expect_not_to_see_any_notification_errors
  end
end
