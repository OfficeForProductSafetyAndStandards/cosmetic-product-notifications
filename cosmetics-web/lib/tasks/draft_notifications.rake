namespace :draft_notifications do
  desc "Migrate notifications to use new task-based flow structure. This task is safe to run multiple times"

  task :migrate_data => :environment do
    ActiveRecord::Base.transaction do
      DraftNotificationData.add_nano_materials
      DraftNotificationData.assign_nano_materials_to_notification
      DraftNotificationData.add_info_to_components
      DraftNotificationData.add_component_nano_material_relation
    end
  end
end

# Namespaced methods used in rake. It is safe to use each method mutiple times, it should not be necessary though.
module DraftNotificationData
  # each NanoElement should be given his own NanoMaterial
  # previously NanoMaterial was containter for all NanoElements withinComponent,
  # it has to change as we add nano materials before adding components
  # and now one NanoMaterial can be used in multiple components in the same notification
  def self.add_nano_materials
    NanoMaterial.all.each do |nano_material|
      next if nano_material.nano_elements.count < 2

      component = nano_material.component
      # create new nano material for next nano elements
      nano_material.nano_elements[1..-1].each do |nano_element|
        new_nano_material = NanoMaterial.create!(component: component)
        nano_element.update!(nano_material_id: new_nano_material.id)
      end
    end
  end

  # in new flow we add nanomaterial first so there is need to assign NanoMaterial
  # to proper notification
  def self.assign_nano_materials_to_notification
    NanoMaterial.all.each do |nano_material|
      if nano_material.component.nil?
        log("NanoMaterial #{nano_material.id} has no component")
        next
      end

      nano_material.notification_id = nano_material.component.notification.id
      nano_material.save
    end
  end

  # In new datastructure, its component that holds information about exposure condition.
  def self.add_info_to_components
    NanoMaterial.all.each do |nano_material|
      next if nano_material.component.nil?

      component = nano_material.component
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
      next if nano_material.component.nil?

      component = nano_material.component

      next if ComponentNanoMaterial.find_by(nano_material: nano_material, component: component)

      ComponentNanoMaterial.create(nano_material: nano_material, component: component)
    end
  end

  def self.log(msg)
    Rails.logger.info("[DRAFT_MIGRATION] #{msg}")
  end
end
