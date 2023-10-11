require "support/matchers/capybara_matchers"

def complete_product_wizard(name: "Product", items_count: 1, nano_materials_count: 0, continue_on_nano: false, continue_on_items: false)
  click_on "Go to question - add product name"
  expect_to_be_on__what_is_product_name_page

  answer_product_name_with name

  answer_do_you_want_to_give_an_internal_reference_with "No"

  answer_is_product_for_under_threes_with "No"

  if !continue_on_nano
    if nano_materials_count > 0
      answer_does_product_contains_nanomaterials_with "Yes", amount: nano_materials_count
    else
      answer_does_product_contains_nanomaterials_with "No"
    end
  else
    expect(page).to have_text("You can add and remove nanomaterials directly from the task list page.")
    click_on "Continue"
  end

  if !continue_on_items
    if items_count > 1
      answer_is_product_multi_item_kit_with "Yes", amount: items_count
    else
      answer_is_product_multi_item_kit_with "No, this is a single product"
    end
  else
    expect(page).to have_text("A multi-item kit must contain, at least, 2 items. If this product is not a multi-item kit you will need to create a new product notification.")
    click_on "Continue"
  end

  upload_product_label

  expect_task_has_been_completed_page

  return_to_task_list_page

  expect_product_task_completed
end

def answer_product_name_with(product_name)
  fill_in "Product name", with: product_name
  click_button "Continue"
end

def answer_do_you_want_to_give_an_internal_reference_with(answer)
  within_fieldset("Do you want to add an internal reference?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_is_product_for_under_threes_with(answer)
  within_fieldset("Is the product intended to be used on children under 3 years old?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_product_contains_nanomaterials_with(answer, amount: 1)
  within("fieldset") do
    page.choose(answer)
    if answer == Fspec::YES
      fill_in "How many nanomaterials?", with: amount
    end
  end
  click_button "Continue"
end

def answer_is_product_multi_item_kit_with(answer, amount: 1)
  within_fieldset("Is the product a multi-item kit?") do
    page.choose(answer)
    if answer == Fspec::YES
      fill_in "How many items does it contain?", with: amount
    end
  end
  click_button "Continue"
end

def upload_product_label
  page.attach_file "spec/fixtures/files/testImage.png"
  click_button "Save and continue"
end

def expect_product_task_blocked
  expect_task_blocked "Create the product"
end

def expect_product_task_completed
  expect_task_completed "Product"
end

def expect_product_label_images(images)
  images_count = images.size

  expect(page).to have_h1("Upload an image of the product label")
  within("#label-images-table") do
    expect(page).to have_css("tr.govuk-table__row", count: images_count)
    images.each do |image|
      case image["virus_scan_status"]
      when "passed"
        expect(page).to have_link(image["name"])
      when "pending"
        expect(page).to have_text("#{image['name']} pending virus scan")
      end
    end
    if images_count > 1
      expect(page).to have_button("Remove", count: images_count)
    else
      expect(page).not_to have_button("Remove")
    end
  end
end
