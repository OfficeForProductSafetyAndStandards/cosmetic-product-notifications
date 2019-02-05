require "application_system_test_case"

class CreateProjectTest < ApplicationSystemTestCase
  setup do
    @project = Investigation::Project.new(description: "new project description", user_title: "project title")
    sign_in_as_user
    visit new_project_path
  end

  teardown do
    logout
  end

  test "can be reached via create page" do
    visit root_path
    click_on "Create new"
    assert_text "Create new"

    choose "type_project", visible: false
    click_on "Continue"

    assert_text "New Project"
  end

  test "first step should be allegation details" do
    assert_text "New Project"
    assert_text "Please provide a title"
    assert_text "Project summary"
  end

  test "first step should require a description" do
    click_on "Continue"
    assert_text "Description can't be blank"
  end

  test "third step should require title" do
    click_on "Continue"
    assert_text "User title can't be blank"
  end

  test "case page should be shown when complete" do
    fill_project_details_and_continue

    assert_current_path(/cases\/\d+/)
  end

  test "confirmation message should be shown when complete" do
    fill_project_details_and_continue

    assert_text "Project was successfully created"
  end

  test "project details should show in overview"
    fill_project_details_and_continue
    assert_text "Project"
    assert_no_text "Product category"
    assert_no_text "Reporter"

  def fill_project_details_and_continue
    fill_in "investigation[description]", with: @project.description
    fill_in "investigation[user_title]", with: @project.user_title
    click_on "Continue"
  end
end
