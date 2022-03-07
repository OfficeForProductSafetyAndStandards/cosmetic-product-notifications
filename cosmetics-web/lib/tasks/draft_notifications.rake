namespace :draft_notifications do
  desc "Migrate notifications to use new task-based flow structure. This task is safe to run multiple times"

  task :migrate_data => :environment do
    ActiveRecord::Base.transaction do
      # need to be first as is using existing nano_material exposure info
      DraftNotificationData.add_info_to_components

      DraftNotificationData.add_nano_materials
      DraftNotificationData.assign_nano_materials_to_notification
      DraftNotificationData.add_component_nano_material_relation
    end
  end

  task :rewrite_state => :environment do
    ActiveRecord::Base.transaction do
      DraftNotificationData.rewrite_state
    end
  end
end

# Namespaced methods used in rake. It is safe to use each method mutiple times, it should not be necessary though.
module DraftNotificationData
  # each NanoElement should be given his own NanoMaterial
  # previously NanoMaterial was containter for all NanoElements withinComponent,
  # it has to change as we add nano materials before adding components
  # and now one NanoMaterial can be used in multiple components in the same notification
  #
  # This method is not backwards compatibile.
  def self.add_nano_materials
    NanoMaterial.all.each do |nano_material|
      nano_elements = NanoElement.where(nano_material_id: nano_material.id)

      next if nano_elements.count < 2

      component = Component.find_by(id: nano_material.component_id)
      next if component.nil?

      # create new nano material for next nano elements
      nano_elements[1..-1].each do |nano_element|
        new_nano_material = NanoMaterial.create!(notification: component.notification)
        nano_element.update!(nano_material_id: new_nano_material.id)
        # add component relation for new nanomaterial
        ComponentNanoMaterial.create(nano_material: new_nano_material, component: component)
      end
    end
  end

  # in new flow we add nanomaterial first so there is need to assign NanoMaterial
  # to proper notification
  def self.assign_nano_materials_to_notification
    NanoMaterial.all.each do |nano_material|
      component = Component.find_by(id: nano_material.component_id)
      if component.nil?
        log("NanoMaterial #{nano_material.id} has no component")
        next
      end

      nano_material.notification_id = component.notification.id
      nano_material.save
    end
  end

  # In new datastructure, its component that holds information about exposure condition.
  # TODO: should it be first?
  def self.add_info_to_components
    NanoMaterial.all.each do |nano_material|
      component = Component.find_by(id: nano_material.component_id)
      next if component.nil?

      component.exposure_routes    = nano_material.exposure_routes
      component.exposure_condition = nano_material.exposure_condition
      if !component.save
        log("Component #{component.id} could not be saved")
        # Some early data issues were causing troubles, save anyway
        component.save(validate: false)
      end
    end
  end

  # In new datastructure, given nano material can be assigned to multiple components
  def self.add_component_nano_material_relation
    NanoMaterial.all.each do |nano_material|
      component = Component.find_by(id: nano_material.component_id)
      next if component.nil?

      # Ommit relations that already exist
      next if ComponentNanoMaterial.find_by(nano_material: nano_material, component: component)

      ComponentNanoMaterial.create(nano_material: nano_material, component: component)
    end
  end

  # TODO: check if new flow makes possible to create empty notification
  def self.rewrite_state
    if !Notification.pluck(:state).uniq.map(&:to_s).include? "draft_complete"
      log("State migration already done")
      return
    end
    # In new flow, we are displaying all notifications that are not empty
    Notification.where(state: NotificationStateConcern::PRODUCT_NAME_ADDED).update_all(state: NotificationStateConcern::EMPTY)
    # old components complete state was different
    Notification.where(state: NotificationStateConcern::COMPONENTS_COMPLETE).update_all(state: NotificationStateConcern::EMPTY)

    notifications = Notification.where(state: 'draft_complete')
    notifications.each do |notification|
      unless notification.missing_information?
        notification.state = NotificationStateConcern::COMPONENTS_COMPLETE
        notification.previous_state = NotificationStateConcern::COMPONENTS_COMPLETE
      else
        notification.state = NotificationStateConcern::PRODUCT_NAME_ADDED
      end
      notification.save!
    end

  end

  def self.log(msg)
    Rails.logger.info("[DRAFT_MIGRATION] #{msg}")
  end
end
