# Any code that reaches this module call will send an alert to Sentry
# This is useful for ensuring that code is actually unused before removing it from the codebase.
# The alert will be transparant to the user, and will only be visible in Sentry.
module UnusedCodeAlerting
  def self.alert
    Sentry.capture_message "Called code marked as unused"
  end
end
