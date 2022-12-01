# Obtains exclusive Postgres transaction level advisory lock if available.
# The lock is automatically released at the end of the current transaction and cannot be released explicitly.
module PostgresTransactionLock
  def self.try_with_lock(lock_name)
    lock_id = Zlib.crc32(lock_name.to_s) # Same string will always return same id value

    ActiveRecord::Base.transaction do
      # tries to aquire lock. Wont block, and we need to return in case lock exist
      # when lock attempt returns false, lock already exists and we don't want to proceed
      # when lock attempt returns true, we aquired the lock and we can perform operation in current transaction
      lock = ActiveRecord::Base.connection.select_value("SELECT pg_try_advisory_xact_lock(#{lock_id})")
      return if lock != true

      yield
    end
  end
end
