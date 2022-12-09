class ReindexOpensearchJob < ApplicationJob
  def perform
    PostgresTransactionLock.try_with_lock("reindex_notifications") do
      ActiveRecord::Base.descendants.each do |model|
        next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

        current_index = model.current_index_name
        new_index = model.create_new_index!

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
