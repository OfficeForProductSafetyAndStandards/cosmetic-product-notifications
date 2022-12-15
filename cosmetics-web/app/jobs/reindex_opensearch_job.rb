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

        logging(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index")
        errors_count = model.import_to_opensearch(index: new_index)

        if errors_count.zero?
          model.swap_index_alias!(to: new_index)
          model.delete_indices!(current_index) if current_index.present?
          logging(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index succeeded")
        else
          model.delete_indices!(new_index)
          logging(model, "Reindexing Opensearch #{model} from #{current_index} index to #{new_index} index failed with #{errors_count} errors while importing")
        end
      end
    end
  end

private

  def logging(model, msg)
    Sidekiq.logger.info "#{model.searchable_log_tag} #{msg}"
  end
end
