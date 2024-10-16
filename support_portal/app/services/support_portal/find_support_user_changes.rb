module SupportPortal
  class FindSupportUserChanges
    def initialize(query:, date_from:, date_to:, action:, sort_by:, sort_direction:)
      @query = query
      @date_from = date_from
      @date_to = date_to
      @action = action
      @sort_by = sort_by
      @sort_direction = sort_direction
      @changes = changes
    end

    def call
      @changes = @changes.where("item_type = ?", item_type) if @action.present?
      if @query.present?
        @changes = @changes.where("users.name ILIKE ?", "%#{@query}%")
                        .or(@changes.where("users.email ILIKE ?", "%#{@query}%"))
                        .or(@changes.where("object->>'name' ILIKE ?", "%#{@query}%"))
                        .or(@changes.where("object->>'reference_number' LIKE ?", "%#{@query}%"))
      end

      if responsible_person_action?
        @changes = if @action.match?(/address/)
                     @changes.where("object_changes->>'address_line_1' IS NOT  NULL")
                                       .or(@changes.where("object_changes->>'address_line_1' IS NOT  NULL"))
                                       .or(@changes.where("object_changes->>'address_line_2' IS NOT  NULL"))
                                       .or(@changes.where("object_changes->>'postal_code' IS NOT  NULL"))
                                       .or(@changes.where("object_changes->>'city' IS NOT  NULL"))
                                       .or(@changes.where("object_changes->>'county' IS NOT  NULL"))
                   else
                     @changes.where("object_changes->>? IS NOT NULL", @action.split("rp_").last)
                   end
      end

      search_user_changes if search_user_action?

      @changes = @changes.where("versions.created_at <= ?", @date_to) if @date_to.present?
      @changes = @changes.where("versions.created_at >= ?", @date_from) if @date_from.present?

      @changes
    end

    def self.call(query: nil, date_from: nil, date_to: nil, action: nil, sort_by: nil, sort_direction: "desc")
      new(query:, date_from:, date_to:, action:, sort_by:, sort_direction:).call
    end

  private

    def changes
      PaperTrail::Version
                  .includes(:item)
                  .joins("LEFT JOIN users ON users.id::text = versions.whodunnit")
                  .where("users.type = ?", "SupportUser")
                  .select("versions.*, COALESCE(users.name, 'Unknown') AS whodunnit")
                  .order(**sort_order)
    end

    def search_user_changes
      @changes = @changes.where("object_changes->>'role' IS NOT NULL") if @action.match?(/role_changed/)
      @changes = @changes.where("object_changes #>> '{deactivated_at, 1}' IS NOT NULL") if @action.match?(/deactivated/)
      @changes = @changes.where("object_changes #>> '{deactivated_at, 0}' IS NOT NULL") if @action.match?(/reactivated/)
    end

    def sort_order
      return { @sort_by => @sort_direction } if @sort_by.present?

      { "created_at" => @sort_direction }
    end

    def item_type
      return "ResponsiblePerson" if responsible_person_action?

      return "Notification" if notification_action?

      "User"
    end

    def responsible_person_action?
      HistorySearch::RP_ACTIONS.pluck(:id).include?(@action&.to_sym)
    end

    def notification_action?
      HistorySearch::NOTIFICATION_ACTIONS.pluck(:id).include?(@action&.to_sym)
    end

    def search_user_action?
      HistorySearch::SEARCH_USER_ACTIONS.pluck(:id).include?(@action&.to_sym)
    end
  end
end
