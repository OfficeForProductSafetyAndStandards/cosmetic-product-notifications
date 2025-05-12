# Purpose: Reindex all models to Opensearch
# Locks the transaction to avoid multiple re-indexing processes running at the same time.
#
# The reindexing process is as follows:
# * Creates a new index
# * Populates the new index
# * If there are any errors during the importing process into the new index:
#   * Keeps the previous index.
#   * Deletes the new index.
# * If the import process succeeds:
#   * Hot-swaps the index used by the service by replacing the index pointed at by the model alias.
#   * Deletes the previous index.
class ReindexOpensearchJob < ApplicationJob
  LOCK_NAME = "reindex_notifications".freeze
  BATCH_SIZE = 50

  def perform
    # Set longer timeouts for bulk operations
    original_timeout = Elasticsearch::Model.client.transport.options[:timeout]
    Elasticsearch::Model.client.transport.options[:timeout] = 120 # Set timeout to 120 seconds

    PostgresDistributedLock.try_with_lock(LOCK_NAME) do
      ActiveRecord::Base.descendants.each do |model|
        next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

        current_index = model.current_index
        new_index = model.create_index!

        log(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index")
        errors_count = model.import_to_opensearch(index: new_index, batch_size: BATCH_SIZE)

        if errors_count.zero?
          model.swap_index_alias!(to: new_index)
          model.delete_indices!(current_index) if current_index.present?
          log(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index succeeded")
        else
          model.delete_indices!(new_index)
          log(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index failed with #{errors_count} errors while importing")
        end
      end
    end
  rescue StandardError => e
    Sidekiq.logger.error "ReindexOpensearchJob failed: #{e.class} - #{e.message}"
    raise e # Re-raise to ensure job is marked as failed
  ensure
    # Reset timeout to original value
    Elasticsearch::Model.client.transport.options[:timeout] = original_timeout if original_timeout
  end

private

  def log(model, msg)
    Sidekiq.logger.info "#{model.opensearch_log_tag} #{msg}"
  end
end
