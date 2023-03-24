class AddNotificationTypeGivenAsToComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :components, :notification_type_given_as, :string
  end
end
