class ChangeHasBeenSentWelcomeEmailInUserAttributes < ActiveRecord::Migration[5.2]
  def change
    UserAttributes.where(has_accepted_declaration: true).update_all("has_been_sent_welcome_email = true")
  end
end
