module NotificationStateConcern
  extend ActiveSupport::Concern

  # states which can go to previous state
  CACHEABLE_PREVIOUS_STATES = %w(ready_for_components components_complete)
  #CACHEABLE_PREVIOUS_STATES = %w(ready_for_components)

  # Indicates which states can be changed
  # key is requested state, value possible state from `previous_state` column.
  STATES_OVERRIDES = {
    "details_complete" => ["ready_for_components", "components_complete"],
    "ready_for_components" => ["components_complete"]
  }

  included do
    include AASM

    aasm whiny_transitions: false, timestamps: true, column: :state do
      state :empty, initial: true
      state :product_name_added

      state :ready_for_nanomaterials
      # state is entangled with view here, this state is used to indicate
      # that multiitem kit step is not defined
      # TODO: rename to something as product_definition_complete
      state :details_complete # only for multiitem

      # indicate that component related steps can be started
      state :ready_for_components

      state :components_complete
      state :notification_complete

      event :add_product_name do
        transitions from: :empty, to: :product_name_added
      end

      event :complete_draft do
        transitions from: :components_complete, to: :draft_complete
      end

      event :submit_notification, after: :cache_notification_for_csv! do
        transitions from: :components_complete, to: :notification_complete,
                    after: proc { __elasticsearch__.index_document } do
          guard do
            !missing_information?
          end
        end
      end

      state :deleted
    end
  end

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

  # TODO: quite entangled
  # This method is only called on product wizard when increasing component count
  # from 1 to n
  def revert_to_details_complete
    return if ['empty', 'product_name_added', 'ready_for_nanomaterials'].include?(self.state)

    raise("This should not be called") if self.components.count != 1
    # we dont want to change state to details complete when its new notification
    # TODO: remove ready_for_nanomaterials and see what happens!

    # Reset first component too
    c = self.components.first
    c.update_state('empty')
    self.update_state!('details_complete')
  end

  def revert_to_ready_for_nanomaterials
    self.update_state('ready_for_nanomaterials')
  end

  def update_state(new_state)
    # puts "********************", new_state, "*********************************"
    # binding.pry if new_state == 'details_complete'
    # self.update(state: new_state)
    # return

    puts "********************", new_state, "*********************************"
    if CACHEABLE_PREVIOUS_STATES.include?(self.state)
      self.update(previous_state: self.state)
    end
    if self.previous_state.present? && STATES_OVERRIDES[new_state]&.include?(self.previous_state)
      self.update(state: self.previous_state)
    else
      self.update(state: new_state)
    end
  end

  def update_state!(new_state)
    self.update(state: new_state)
  end
end
