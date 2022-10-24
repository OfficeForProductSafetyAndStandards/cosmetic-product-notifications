# Advisory locks accept 2 int argumests. First is commonly used as namespaced, second as 'operation'

module AdvisoryLock
  SEARCH = "search".freeze

  REINDEX_NOTIFICATIONS = "reindex_notifications".freeze

  NAMESPACES = {
    SEARCH => 0,
  }.freeze

  OPERATIONS = {
    REINDEX_NOTIFICATIONS => 0,
  }.freeze
end
