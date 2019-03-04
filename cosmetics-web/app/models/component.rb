class Component < ApplicationRecord
  include AASM
  include NotificationProperties

  belongs_to :notification

  has_many :exact_formulas, dependent: :destroy
  has_many :range_formulas, dependent: :destroy
  has_many :trigger_questions, dependent: :destroy
  has_one_attached :formulation_file

  before_save :add_shades, if: :will_save_change_to_shades?

  aasm whiny_transitions: false, column: :state do
    state :empty, initial: true
    state :component_complete, enter: :update_notification_state

    event :add_shades do
      transitions from: :empty, to: :component_complete
    end
  end

  def prune_blank_shades
    return if self[:shades].nil?

    self[:shades] = self[:shades].select(&:present?)
  end

  def sub_category
    get_parent_category(sub_sub_category)
  end

  def root_category
    get_parent_category(sub_category)
  end

private

  def update_notification_state
    notification&.set_single_or_multi_component!
  end

  def get_parent_category(category)
    PARENT_OF_CATEGORY[category]
  end
end
