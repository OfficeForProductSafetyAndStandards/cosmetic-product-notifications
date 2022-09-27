namespace :draft_notifications do
  desc "Change state of notifications. This task can be run just once"
  task rewrite_state: :environment do
    ActiveRecord::Base.transaction do
      DraftNotificationData.rewrite_state
    end
  end
end

# Namespaced methods used in rake. It is safe to use each method mutiple times, it should not be necessary though.
module DraftNotificationData
  # TODO: check if new flow makes possible to create empty notification
  def self.rewrite_state
    # rubocop:disable Rails/UniqBeforePluck
    unless Notification.pluck(:state).uniq.map(&:to_s).include? "draft_complete"
      log("State migration already done")
      return
    end
    # rubocop:enable Rails/UniqBeforePluck
    # In new flow, we are displaying all notifications that are not empty
    Notification.where(state: NotificationStateConcern::PRODUCT_NAME_ADDED).update_all(state: NotificationStateConcern::EMPTY)

    # old components complete state was different - was set when one of the components was complete
    # in new flow, its when all components are complete and indicates that product is ready for submition
    Notification.where(state: NotificationStateConcern::COMPONENTS_COMPLETE).update_all(state: NotificationStateConcern::EMPTY)

    # we dont need this state anymore
    Notification.where(state: "import_country_added").update_all(state: NotificationStateConcern::EMPTY)

    Notification.where(state: "notification_file_imported").update_all(state: NotificationStateConcern::EMPTY)

    notifications = Notification.where(state: "draft_complete")
    notifications.each do |notification|
      if notification.missing_information?
        notification.state = NotificationStateConcern::PRODUCT_NAME_ADDED
      else
        notification.state = NotificationStateConcern::COMPONENTS_COMPLETE
        notification.previous_state = NotificationStateConcern::COMPONENTS_COMPLETE
      end
      notification.save!
    end
  end

  def self.log(msg)
    Rails.logger.info("[DRAFT_MIGRATION] #{msg}")
  end
end
