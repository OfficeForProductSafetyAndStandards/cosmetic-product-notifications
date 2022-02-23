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

  # State cache and overrides
  #
  # Sometimes, when user changes higher state to lower - in practice, only
  # when adding nanos after higher steps were completed, after finishing
  # nano wizard we want to go to the previous state. This is achieved by cacheing
  # higher state and restoring it when certain state update is triggered.

  # states which can be saved as previous state column
  CACHEABLE_PREVIOUS_STATES = [READY_FOR_COMPONENTS, COMPONENTS_COMPLETE].freeze

  # Indicates which states can be changed
  # key is requested state, value possible state from `previous_state` column.
  STATES_OVERRIDES = {
    DETAILS_COMPLETE => [READY_FOR_COMPONENTS, COMPONENTS_COMPLETE],
    READY_FOR_COMPONENTS => [COMPONENTS_COMPLETE],
  }.freeze

  DISABLED_OVERRIDES_FOR = {
    COMPONENTS_COMPLETE => [READY_FOR_COMPONENTS],
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

      state DELETED
    end
  end

  def set_state_on_product_wizard_completed!
    if nano_materials.count.positive?
      update_state("ready_for_nanomaterials")
    elsif multi_component?
      update_state("details_complete")
    else
      update_state("ready_for_components")
    end
  end

  def try_to_complete_nanomaterials!
    return if state != "ready_for_nanomaterials"

    if nano_materials.map(&:nano_elements).flatten.all?(&:completed?)
      if multi_component?
        update_state("details_complete")
      else
        update_state("ready_for_components")
      end
    end
  end

  def try_to_complete_components!
    if components.all? { |c| c.state == "component_complete" }
      update_state("components_complete")
    end
  end

  def notification_product_wizard_completed?
    !%w[empty product_name_added].include?(state)
  end

  # TODO: quite entangled
  # This method is only called on product wizard when increasing component count
  # from 1 to n
  def revert_to_details_complete
    return if %w[empty product_name_added ready_for_nanomaterials].include?(state)

    raise("This should not be called") if components.count != 1

    # we dont want to change state to details complete when its new notification
    # eg. remove ready_for_nanomaterials and see what happens!

    # Reset first component too
    c = components.first
    c.update_state("empty")
    update_state!(DETAILS_COMPLETE)
  end

  def revert_to_ready_for_nanomaterials
    update_state(READY_FOR_NANOMATERIALS)
  end

  def update_state(new_state, only_downgrade: false)
    if only_downgrade && (new_state.to_sym == READY_FOR_COMPONENTS && state.to_sym == READY_FOR_NANOMATERIALS)
      return
    end

    if CACHEABLE_PREVIOUS_STATES.include?(state.to_sym)
      update(previous_state: state)
    end
    # Try to revert to previous state
    if previous_state.present? && STATES_OVERRIDES[new_state.to_sym]&.include?(previous_state.to_sym) &&
        !DISABLED_OVERRIDES_FOR[state.to_sym]&.include?(new_state.to_sym)
      # but only when transision is allowed
      update(state: previous_state)
    else
      update(state: new_state)
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
