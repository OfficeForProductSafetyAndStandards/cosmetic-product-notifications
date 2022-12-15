# Delete old unused Opensearch indices for all models that use the Searchable module.
# This is to delete dangling indices that got partially created/filled and never got tagged as the current index, as they
# won't be cleaned up by the ReindexOpensearchJob.
class DeleteOldOpensearchIndicesJob < ApplicationJob
  def perform
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

      old_indices = model.previous_indices

      if old_indices.any?
        to_delete = old_indices.join(",")
        Sidekiq.logger.info "Found #{old_indices.size} old Opensearch indices for #{model}: #{to_delete}"
        model.delete_indices!(to_delete)
        Sidekiq.logger.info "#{old_indices.size} old Opensearch indices for #{model} got deleted"
      else
        Sidekiq.logger.info "No old Opensearch indices found for #{model} to be deleted"
      end
    end
  end
end
