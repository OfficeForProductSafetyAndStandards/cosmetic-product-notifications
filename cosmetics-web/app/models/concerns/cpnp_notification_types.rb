module CpnpNotificationTypes
  def get_notification_type(id)
    NOTIFICATION_TYPE_ID[id]
  end

  NOTIFICATION_TYPE_ID = {
    1 => :predefined,
    2 => :exact,
    3 => :range,
  }.freeze
end
