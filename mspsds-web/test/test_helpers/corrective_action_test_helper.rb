module CorrectiveActionTestHelper
  def fill_in_corrective_action_details corrective_action
    fill_in "corrective_action_summary", with: corrective_action.summary
    fill_in "corrective_action_details", with: corrective_action.details
    fill_autocomplete "legislation-picker", with: corrective_action.legislation
    fill_in "Day", with: corrective_action.date_decided.day
    fill_in "Month", with: corrective_action.date_decided.month
    fill_in "Year", with: corrective_action.date_decided.year
  end

  def add_corrective_action_attachment(filename:, description:)
    choose "corrective_action_related_file_yes", visible: false
    attach_file "corrective_action[file][file]", Rails.root + "test/fixtures/files/#{filename}"
    fill_in "Attachment description", with: description
  end
end
