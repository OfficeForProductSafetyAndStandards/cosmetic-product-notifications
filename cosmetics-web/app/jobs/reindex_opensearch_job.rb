class ReindexOpensearchJob < ApplicationJob
  def perform
    PostgresTransactionLock.try_with_lock("reindex_notifications") do
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
