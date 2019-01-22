require "application_system_test_case"

class InvestigationStiElasticsearchTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "elasticsearch index should update for each type of new or existing case" do
    # If you experience unreliable elasticsearch behaviour for large number of cases use long sequence to replicate it
    # random_long_type_sequence = (1..10).map{|i| rand(1..3)}
    short_type_sequence = [1,2,3,1]
    short_type_sequence.each_with_index do |type, index|
      description = "CaseDescription#{index}#{index}#{index}"
      create_new_case(type, description)

      case_path = current_path
      assert_current_path(/cases\/\d+/)

      check_highlights_contain(description)
      change_status_to_closed(case_path)
      check_highlights_not_contain(description)
    end
  end

  def create_new_case(type, description)
    case type
    when 1
      create_new_allegation(description)
    when 2
      create_new_question(description)
    else
      create_new_project(description)
    end
  end

  def create_new_allegation(description)
    visit new_allegation_path
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_on "Continue"
    click_on "Continue"
    fill_in "allegation[description]", with: description
    fill_autocomplete "hazard-type-picker", with: "Blunt force"
    fill_autocomplete "product-type-picker", with: "Small Electronics"
    click_on "Continue"
  end

  def create_new_question(description)
    visit new_question_path
    choose("reporter[reporter_type]", visible: false, match: :first)
    click_on "Continue"
    click_on "Continue"
    fill_in "question[user_title]", with: "Question title"
    fill_in "question[description]", with: description
    click_on "Continue"
  end

  def create_new_project(description)
    visit new_project_path
    fill_in "investigation[description]", with: description
    fill_in "investigation[user_title]", with: "Project title"
    click_on "Continue"
  end

  def check_highlights_contain(description)
    visit investigations_path
    fill_in "q", with: description, visible: false
    click_on "Apply filters"
    assert_text "Description\n#{description}"
  end

  def change_status_to_closed(case_path)
    visit case_path
    click_on "Change", match: :first
    assert_text "Status information"
    choose "Closed", visible: false
    click_on "Save"
  end

  def check_highlights_not_contain(description)
    visit investigations_path
    fill_in "q", with: description, visible: false
    click_on "Apply filters"
    assert_no_text "Description\n#{description}"
  end
end
