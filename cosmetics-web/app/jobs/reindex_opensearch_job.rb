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

        Sidekiq.logger.info "Reindexing #{model} to Opensearch #{new_index} index..."
        errors_count = model.import(index: new_index, scope: "opensearch", refresh: true)

        if errors_count.zero?
          import_count = model.index_docs_count(new_index)
          Sidekiq.logger.info "Imported #{import_count} records for #{model} to Opensearch #{new_index} index"

          model.swap_index_alias!(to: new_index)
          Sidekiq.logger.info "Swapped Opensearch index for #{model} from #{current_index} to #{new_index}"

          if current_index.present?
            model.__elasticsearch__.delete_index!(index: current_index)
          end

          Sidekiq.logger.info "Deleted Opensearch index #{current_index} for #{model}"
        else
          Sidekiq.logger.info "Got #{errors_count} errors while importing #{model} records to Opensearch #{new_index} index"
          Sidekiq.logger.info "Keeping #{current_index} index"

          model.__elasticsearch__.delete_index!(index: new_index)
          Sidekiq.logger.info "#{new_index} deleted"
        end
      end
    end
  end
end
