module NotificationStateConcern
  def set_state_on_product_wizard_completed!
    if self.nano_materials.count > 0
      self.update_state('ready_for_nanomaterials')
    else
      if self.multi_component?
        self.update_state('details_complete')
      else
        self.update_state('ready_for_components')
      end
    end
  end

  def try_to_complete_nanomaterials!
    return if state != 'ready_for_nanomaterials'

    if nano_materials.map(&:nano_elements).flatten.all? { |n| n.completed? }
      if self.multi_component?
        self.update_state('details_complete')
      else
        self.update_state('ready_for_components')
      end
    end
  end

  def try_to_complete_components!
    if components.all? { |c| c.state == 'component_complete' }
      self.update_state('components_complete')
    end
  end

  def notification_product_wizard_completed?
    !['empty', 'product_name_added'].include?(self.state)
  end

  def revert_to_details_complete
    # we dont want to change state to details complete when its new notification
    return if ['empty', 'product_name_added'].include?(self.state)

    self.update_state('details_complete')
  end

  def revert_to_ready_for_nanomaterials
    self.update_state('ready_for_nanomaterials')
  end

  def update_state(state)
    self.update(state: state)
  end
end
