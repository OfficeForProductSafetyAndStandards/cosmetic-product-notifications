module SupportPortal
  class NotificationSearch
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :q, :string
    attribute :status, array: true
    attribute :date_from, :date
    attribute :date_to, :date
    attribute :product_name_sort_order, :string, default: "asc"
    attribute :notification_complete_at_sort_order, :string, default: "asc"

    validates :status, inclusion: %w[live archived deleted], allow_nil: true
    validates :date_from, presence: { message: "From date cannot be blank" }, if: -> { date_to.present? }
    validates :date_to, presence: { message: "To date cannot be blank" }, if: -> { date_from.present? }
    validates :product_name_sort_order, inclusion: %w[asc desc]
    validates :notification_complete_at_sort_order, inclusion: %w[asc desc]

    validate :date_from_is_before_date_to

    def search
      states = status.nil? ? %w[notification_complete archived deleted] : status.map { |s| map_status_to_state(s) }
      non_deleted_states = states - %w[deleted]

      notifications = ::Notification.left_joins(components: %i[ingredients])
        .where("notifications.product_name ILIKE ?", "%#{q}%")
        .or(::Notification.left_joins(components: %i[ingredients]).where("ingredients.inci_name ILIKE ?", "%#{q}%"))
        .or(::Notification.left_joins(components: %i[ingredients]).where(reference_number: q))
        .where(state: non_deleted_states)
        .where(notification_complete_at: date_from.presence..date_to.presence)
        .select(:id, :product_name, :reference_number, :notification_complete_at, :state)

      if states.include?("deleted")
        notifications = ::Notification.union_all(notifications,
          ::DeletedNotification.left_joins(notification: { components: %i[ingredients] })
            .where("deleted_notifications.product_name ILIKE ?", "%#{q}%")
            .or(::DeletedNotification.left_joins(notification: { components: %i[ingredients] }).where("ingredients.inci_name ILIKE ?", "%#{q}%"))
            .or(::DeletedNotification.left_joins(notification: { components: %i[ingredients] }).where(reference_number: q))
            .where(state: "deleted")
            .where(notification_complete_at: date_from.presence..date_to.presence)
            .select(:id, :product_name, :reference_number, :notification_complete_at, :state)
          )
      end

      notifications.order(product_name: product_name_sort_order.to_sym).order(notification_complete_at: notification_complete_at_sort_order.to_sym)
    end

  private

    def map_status_to_state(status)
      case status
      when "live"
        "notification_complete"
      when "archived"
        "archived"
      when "deleted"
        "deleted"
      end
    end

    def date_from_is_before_date_to
      errors.add(:date_from, "The from date must be before the to date") if date_from.present? && date_to.present? && date_from >= date_to
    end
  end
end
