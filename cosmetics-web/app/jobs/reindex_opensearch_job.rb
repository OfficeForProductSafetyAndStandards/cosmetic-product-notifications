class ReindexOpensearchJob < ApplicationJob
  def perform
    ActiveRecord::Base.transaction do
      # tries to aquire lock. Wont block, and we need to return in case lock exist
      lock = ActiveRecord::Base.connection.execute("SELECT pg_try_advisory_xact_lock(#{AdvisoryLock::NAMESPACES[AdvisoryLock::SEARCH]}, #{AdvisoryLock::OPERATIONS[AdvisoryLock::REINDEX_NOTIFICATIONS]})")
      # lock.result returns such array: [[true]] or [[false]]
      # when false, lock exists and we don't want to proceed
      # when true, we aquired the lock and we can perform operation in current transaction
      return unless lock.values.first.first

      total = 0
      ActiveRecord::Base.descendants.each do |model|
        next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

        model.__elasticsearch__.create_index! unless model.__elasticsearch__.index_exists?

        total += 1
        if model.respond_to?(:opensearch)
          model.opensearch.import
        else
          model.import
        end
      end

      Sidekiq.logger.info "Imported #{total} records to Opensearch"
    end
  end
end
