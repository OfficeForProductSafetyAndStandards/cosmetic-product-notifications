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

  def perform
    PostgresDistributedLock.try_with_lock(LOCK_NAME) do
      ActiveRecord::Base.descendants.each do |model|
        next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

        current_index = model.current_index
        new_index = model.create_index!

        Sidekiq.logger.info "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index..."
        errors_count = model.import(index: new_index, scope: "opensearch", refresh: true)

        if errors_count.zero?
          model.swap_index_alias!(to: new_index)
          if current_index.present?
            model.__elasticsearch__.delete_index!(index: current_index)
            Sidekiq.logger.info "Deleted Opensearch index #{current_index} for #{model}"
          end
        else
          Sidekiq.logger.info "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index failed with #{errors_count} errors during the import"
          model.__elasticsearch__.delete_index!(index: new_index)
          Sidekiq.logger.info "Kept previous Opensearch index #{current_index} and deleted the new index #{new_index}"
        end
      end
    end
  end
end
