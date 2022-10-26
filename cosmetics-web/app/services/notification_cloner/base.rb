require "notification_cloner/attributes"

module NotificationCloner
  class Base
    # Problem: how to clone nano_materials?
    #
    class << self
      def clone(old_notification)
        ActiveRecord::Base.transaction do
          new_notification = clone_notification(old_notification)
          cloned_components     = clone_components(new_notification, old_notification)
          cloned_nano_materials = clone_nano_materials(new_notification, old_notification)

          reassign_nano_materials(cloned_components, cloned_nano_materials)

          new_notification.source_notification = old_notification
          new_notification.save!
          new_notification
        end
      end

      def clone_notification(old_notification)
        new_notification = clone_model(old_notification, NotificationCloner::Attributes::NOTIFICATION)
        new_notification.product_name = "Copy of #{old_notification.product_name}"
        new_notification.save!
        new_notification
      end

      def clone_components(new_notification, old_notification)
        old_notification.components.map do |old_component|
          new_component = clone_model(old_component, NotificationCloner::Attributes::COMPONENT)
          new_component.notification = new_notification

          clone_ingredients(old_component, new_component)

          clone_cmrs(old_component, new_component)

          new_component.save!
          new_component
        end
      end

      def clone_nano_materials(new_notification, old_notification)
        old_notification.nano_materials.map do |nano|
          nano_material = clone_model(nano, NotificationCloner::Attributes::NANOMATERIAL)
          nano_material.notification = new_notification
          nano_material.save!
          nano_material
        end
      end

      def clone_ingredients(old_component, new_component)
        old_component.ingredients.each do |old_ingredient|
          new_ingredient = clone_model(old_ingredient, NotificationCloner::Attributes::INGREDIENT)
          new_ingredient.component = new_component
          new_ingredient.save!
        end
      end

      def clone_cmrs(old_component, new_component)
        old_component.cmrs.each do |old_cmsr|
          new_cmsr = clone_model(old_cmsr, NotificationCloner::Attributes::CMR)
          new_cmsr.component = new_component
          new_cmsr.save!
        end
      end

      def reassign_nano_materials(cloned_components, cloned_nano_materials)
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

      def clone_model(model, attributes_to_clone)
        new_model = model.class.new
        attributes_to_clone.each do |attribute|
          new_model[attribute] = model[attribute]
        end
        new_model.cloned_from = model
        new_model
      end
    end
  end
end
