module SupportPortal
  class HistorySearch
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :query, :string
    attribute :date_from, :date
    attribute :date_to, :date
    attribute :sort_direction, :string, default: "desc"
    attribute :sort_by, :string
    attribute :action, :string

    validates :date_from, presence: { message: "From date cannot be blank" }, if: -> { date_to.present? }
    validates :date_to, presence: { message: "To date cannot be blank" }, if: -> { date_from.present? }

    validate :date_from_is_before_date_to

    RP_ACTIONS =
      [
        OpenStruct.new(id: :rp_name, name: "Change to Responsible Person Name"),
        OpenStruct.new(id: :rp_address, name: "Change to Responsible Person Address"),
        OpenStruct.new(id: :rp_account_type, name: "Change to Responsible Person Business type"),
      ].freeze

    NOTIFICATION_ACTIONS =
      [
        OpenStruct.new(id: :notification, name: "Change to Notification"),
      ].freeze

    SEARCH_USER_ACTIONS =
      [
        OpenStruct.new(id: :search_user_deactivated, name: "Deactivate account"),
        OpenStruct.new(id: :search_user_reactivated, name: "Reactivate account"),
        OpenStruct.new(id: :search_user_role_changed, name: "User role change"),
      ].freeze

    ACTIONS = RP_ACTIONS + NOTIFICATION_ACTIONS + SEARCH_USER_ACTIONS

    def search
      FindSupportUserChanges.call(**attributes.to_h.symbolize_keys)
    end

    def actions
      ACTIONS
    end

  private

    def date_from_is_before_date_to
      errors.add(:date_from, "The from date must be before the to date") if date_from.present? && date_to.present? && date_from >= date_to
    end
  end
end
