class AddHasBeenSentWelcomeEmailToUserAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :user_attributes, :has_been_sent_welcome_email, :boolean
  end
end
