module NotificationStateConcern
  extend ActiveSupport::Concern

  EMPTY = :empty
  PRODUCT_NAME_ADDED = :product_name_added
  READY_FOR_NANOMATERIALS = :ready_for_nanomaterials
  DETAILS_COMPLETE = :details_complete
  READY_FOR_COMPONENTS = :ready_for_components
  COMPONENTS_COMPLETE = :components_complete
  NOTIFICATION_COMPLETE = :notification_complete
  DELETED = :deleted

  DISPLAYABLE_INCOMPLETE_STATES = [
    PRODUCT_NAME_ADDED,
    READY_FOR_NANOMATERIALS,
    DETAILS_COMPLETE,
    READY_FOR_COMPONENTS,
    COMPONENTS_COMPLETE,
  ].freeze

  # State cache and overrides
  #
  # Sometimes, when user changes higher state to lower - in practice, only
  # when adding nanos after higher steps were completed, after finishing
  # nano wizard we want to go to the previous state. This is achieved by cacheing
  # higher state and restoring it when certain state update is triggered.
  # In practice, this is *complicated mechanism*. It is well tested,
  # the best thing to understand it is to read feature specs and temporary remove
  # some values from data structures below to see what happens.

  # states which can be saved as previous state column
  CACHEABLE_PREVIOUS_STATES = [READY_FOR_COMPONENTS, COMPONENTS_COMPLETE].freeze

  # Indicates which states can be changed
  # key is requested state, value possible state from `previous_state` column.
  STATES_OVERRIDES = {
    DETAILS_COMPLETE => [READY_FOR_COMPONENTS, COMPONENTS_COMPLETE],
    READY_FOR_COMPONENTS => [COMPONENTS_COMPLETE],
  }.freeze

  included do
    include AASM

    aasm whiny_transitions: false, timestamps: true, column: :state do
      state EMPTY, initial: true
      state PRODUCT_NAME_ADDED

      state READY_FOR_NANOMATERIALS

      # state is entangled with view here, this state is used to indicate
      # that multiitem kit step is not defined
      state DETAILS_COMPLETE # only for multiitem

      # indicate that component related steps can be started
      state READY_FOR_COMPONENTS

      state COMPONENTS_COMPLETE
      state NOTIFICATION_COMPLETE

      event :add_product_name do
        transitions from: EMPTY, to: PRODUCT_NAME_ADDED
      end

      event :submit_notification, after: :cache_notification_for_csv! do
        transitions from: COMPONENTS_COMPLETE, to: NOTIFICATION_COMPLETE,
                    after: proc { __elasticsearch__.index_document } do
          guard do
            !missing_information?
          end
        end
      end

      state DELETED
    end
  end

  def set_state_on_product_wizard_completed!
    if nano_materials.count.positive?
      update_state(READY_FOR_NANOMATERIALS)
    elsif multi_component?
      update_state(DETAILS_COMPLETE)
    else
      update_state(READY_FOR_COMPONENTS)
    end
  end

  def try_to_complete_nanomaterials!
    return if state != "ready_for_nanomaterials"

    if nano_materials.map(&:nano_elements).flatten.all?(&:completed?)
      if multi_component?
        update_state(DETAILS_COMPLETE)
      else
        update_state(READY_FOR_COMPONENTS)
      end
    end
  end

  def try_to_complete_components!
    if components.all?(&:component_complete?)
      update_state(COMPONENTS_COMPLETE)
    end
  end

  def notification_product_wizard_completed?
    [EMPTY, PRODUCT_NAME_ADDED].exclude?(state)
  end

  # TODO: quite entangled
  # This method is only called on product wizard when increasing component count
  # from 1 to n
  def revert_to_details_complete
    return if [EMPTY, PRODUCT_NAME_ADDED, READY_FOR_NANOMATERIALS].include?(state.to_sym)

    raise("This should not be called") if components.count != 1

    # we dont want to change state to details complete when its new notification
    # eg. remove ready_for_nanomaterials and see what happens!

    # Reset first component too
    c = components.first
    c.update_state(EMPTY)
    update_state!(DETAILS_COMPLETE)
  end

  def revert_to_ready_for_nanomaterials
    update_state(READY_FOR_NANOMATERIALS)
  end

  def update_state(new_state, only_downgrade: false)
    return if only_downgrade && state_lower_than?(new_state.to_sym)

    original_state = state.to_sym
    if previous_state.present? && STATES_OVERRIDES[new_state.to_sym]&.include?(previous_state.to_sym)
      update(state: previous_state)
    else
      update(state: new_state)
    end
    if CACHEABLE_PREVIOUS_STATES.include?(original_state)
      update(previous_state: original_state)
    end
  end

  def update_state!(new_state)
    update(state: new_state)
  end

  def reset_previous_state!
    update(previous_state: nil)
  end

  def state_lower_than?(state)
    states = self.class.aasm.states.map(&:name)
    states.index(self.state.to_sym) < states.index(state)
  end
end
