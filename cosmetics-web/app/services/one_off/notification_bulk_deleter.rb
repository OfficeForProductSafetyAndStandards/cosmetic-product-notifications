module OneOff
  class NotificationBulkDeleter
    def initialize(filepath)
      @filepath = filepath
    end

    def call
      found_references = notifications_to_delete.map(&:reference_number).map(&:to_s)
      missing_references = references_to_delete - found_references

      log "Attempted to delete #{references_to_delete.size} notifications"
      log "Deleting #{found_references.count} notifications"
      log "#{missing_references.size} references did not match any notification in the service"
      log "References not found: #{missing_references}" if missing_references.any?

      notifications_to_delete.destroy_all

      log "Deleted notifications: #{found_references}" if found_references.any?
    end

  private

    def log(msg)
      Rails.logger.info "[NotificationBulkDeleter] #{msg}"
    end

    def notifications_to_delete
      @notifications_to_delete ||= Notification.where(reference_number: references_to_delete)
    end

    def references_to_delete
      @references_to_delete ||= parse_references_to_delete
    end

    def parse_references_to_delete
      File.readlines(@filepath).map { |ref| ref.delete("^0-9") } # Our DB only stores the integer code
                               .map { |ref| ref.sub(/^[0]*/, "") } # Removes leading "0"s as they're not stored in DB
    end
  end
end
