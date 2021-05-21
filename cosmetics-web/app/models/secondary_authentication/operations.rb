module SecondaryAuthentication
  module Operations
    DEFAULT = "secondary_authentication".freeze
    RESET_PASSWORD = "reset_password".freeze
    INVITE_USER = "invite_user".freeze
    UNLOCK = "unlock_operation".freeze
    CHANGE_PASSWORD = "change_password".freeze
    CHANGE_EMAIL_ADDRESS = "change_email_address".freeze
    DELETE_NOTIFICATION = "delete_notification".freeze
    SETUP_APP_AUTHENTICATION = "setup_app_authentication".freeze
    SETUP_SMS_AUTHENTICATION = "setup_sms_authentication".freeze

    TIMEOUTS = {
      DEFAULT => 7 * 24 * 3600, # 7 days
      RESET_PASSWORD => 300, # 5 minutes
      CHANGE_PASSWORD => 300, # 5 minutes
      CHANGE_EMAIL_ADDRESS => 300, # 5 minutes
      INVITE_USER => 300, # 5 minutes
      UNLOCK => 300, # 5 minutes
      DELETE_NOTIFICATION => 900, # 15 minutes
      SETUP_APP_AUTHENTICATION => 300, # 5 minutes
      SETUP_SMS_AUTHENTICATION => 300, # 5 minutes
    }.freeze
  end
end
