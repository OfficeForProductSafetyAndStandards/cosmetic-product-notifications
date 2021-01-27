class NotificationDeleteService
  def initialize(notification, submit_user = nil)
    @notification = notification
    @submit_user = submit_user
  end

  def call
    unless @notification.can_be_deleted?
      raise Notification::DeletionPeriodExpired
    end

    ActiveRecord::Base.transaction do
      NotificationDeleteLog.create! do |n|
        n.notification_product_name = @notification.product_name
        n.submit_user = @submit_user
        n.responsible_person_id = @notification.responsible_person_id
        n.notification_created_at = @notification.created_at
        n.notification_updated_at = @notification.updated_at
        n.cpnp_reference = @notification.cpnp_reference
      end
      @notification.destroy!
    end
  end
end
