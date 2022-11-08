require "notification_cloner/attributes"

module NotificationCloner
  class Base
    def self.clone(old_notification, new_notification)
      ActiveRecord::Base.transaction do
        new_notification = clone_notification(old_notification, new_notification)
        cloned_components     = clone_components(new_notification, old_notification)
        cloned_nano_materials = clone_nano_materials(new_notification, old_notification)

        reassign_nano_materials(cloned_components, cloned_nano_materials)

        new_notification.source_notification = old_notification
        new_notification.save!
        new_notification
      end
      job = CopyImageUploadsJob.perform_later(old_notification.id, new_notification.id)
      JobTracker.save_job_id(new_notification.id, job.provider_job_id)

      new_notification
    end

    def self.clone_notification(old_notification, new_notification)
      new_notification = clone_model(old_notification, NotificationCloner::Attributes::NOTIFICATION, use_model: new_notification)
      new_notification.save!
      new_notification
    end

    def self.clone_components(new_notification, old_notification)
      old_notification.components.map do |old_component|
        new_component = clone_model(old_component, NotificationCloner::Attributes::COMPONENT)
        new_component.notification = new_notification

        clone_ingredients(old_component, new_component)

        clone_cmrs(old_component, new_component)

        new_component.save!
        new_component
      end
    end

    def self.clone_nano_materials(new_notification, old_notification)
      old_notification.nano_materials.map do |nano|
        nano_material = clone_model(nano, NotificationCloner::Attributes::NANOMATERIAL)
        nano_material.notification = new_notification
        nano_material.save!
        nano_material
      end
    end

    def self.clone_ingredients(old_component, new_component)
      old_component.ingredients.each do |old_ingredient|
        new_ingredient = clone_model(old_ingredient, NotificationCloner::Attributes::INGREDIENT)
        new_ingredient.component = new_component
        new_ingredient.save!
      end
    end

    def self.clone_cmrs(old_component, new_component)
      old_component.cmrs.each do |old_cmsr|
        new_cmsr = clone_model(old_cmsr, NotificationCloner::Attributes::CMR)
        new_cmsr.component = new_component
        new_cmsr.save!
      end
    end

    def self.reassign_nano_materials(cloned_components, cloned_nano_materials)
      # first, create a index of nano_materials
      # key is old nano id, value new nano id

      nano_materials_index = {}
      cloned_nano_materials.each do |cloned_nano_material|
        nano_materials_index[cloned_nano_material.cloned_from.id] = cloned_nano_material.id
      end

      cloned_components.each do |component|
        nano_ids = component.cloned_from.nano_material_ids
        component.nano_material_ids = nano_ids.map { |id| nano_materials_index[id] }
        component.save!
      end
    end

    def self.clone_model(model, attributes_to_clone, use_model: nil)
      new_model = use_model || model.class.new

      attributes_to_clone.each do |attribute|
        new_model[attribute] = model[attribute]
      end
      new_model.cloned_from = model
      new_model
    end
  end
end
