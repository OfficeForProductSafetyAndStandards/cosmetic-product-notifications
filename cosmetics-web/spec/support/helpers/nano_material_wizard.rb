require "support/matchers/capybara_matchers"

def complete_nano_material_wizard(name, nano_material_number: nil, purposes: %w[Colourant], from_add: false)
  unless from_add
    if nano_material_number
      click_on "Nanomaterial ##{nano_material_number}"
    else
      click_link name
    end
  end

  answer_what_is_purpose_of_nanomaterial_with(purposes)
  answer_inci_name_with name

  answer_is_nanomaterial_listed_in_ec_regulation_with("Yes", nanomaterial_name: name)
  answer_does_nanomaterial_conform_to_restrictions_with("Yes", nanomaterial_name: name)

  expect_task_has_been_completed_page

  return_to_tasks_list_page
  expect_nano_material_task_completed name
end

def answer_inci_name_with(name)
  fill_in "nano_material_inci_name", with: name
  click_button "Save and continue"
end

def answer_what_is_purpose_of_nanomaterial_with(purposes)
  within_fieldset("What is the purpose of this nanomaterial?") do
    page.choose "Colourant, Preservative or UV filter"
    purposes.each do |purpose|
      page.check(purpose)
    end
  end
  click_button "Continue"
end

def answer_is_nanomaterial_listed_in_ec_regulation_with(answer, nanomaterial_name:)
  fieldset = find("fieldset")
  legend_regex = /Is #{nanomaterial_name} listed in EC regulation 1223.2009, Annex/
  legend_text = fieldset.find("legend h1").text
  unless legend_text&.match?(legend_regex)
    raise("Can not locate proper fieldset")
  end

  within(fieldset) do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_nanomaterial_conform_to_restrictions_with(answer, nanomaterial_name:)
  fieldset = find("fieldset")
  legend_regex = /Does the #{nanomaterial_name} conform to the restrictions set out in Annex/
  legend_text = fieldset.find("legend h1").text
  unless legend_text&.match?(legend_regex)
    raise("Can not locate proper fieldset")
  end

  within(fieldset) do
    page.choose(answer)
  end
  click_button "Continue"
end

def expect_nano_material_task_completed(name)
  expect_task_completed name
end

def expect_nano_material_task_not_started(name)
  expect_task_not_started name
end

def select_nano_materials_and_remove(answers)
  within_fieldset("Select which nanomaterial(s) to remove") do
    answers.each do |answer|
      page.check(answer)
    end
  end
  click_button "Delete and continue"
end
