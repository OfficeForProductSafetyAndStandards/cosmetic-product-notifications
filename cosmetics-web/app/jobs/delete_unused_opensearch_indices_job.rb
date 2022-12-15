# Delete unused Opensearch indices for all models that use the Searchable module.
# This is to delete dangling indices that got partially created/filled and never got tagged as the current index, as they
# won't be cleaned up by the ReindexOpensearchJob.
class DeleteUnusedOpensearchIndicesJob < ApplicationJob
  def perform
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

      unused_indices = model.unused_indices

      if unused_indices.any?
        to_delete = unused_indices.join(",")
        logging(model, "Found #{unused_indices.size} unused Opensearch indices for #{model}: #{to_delete}")
        model.delete_indices!(to_delete)
        logging(model, "Deleted #{unused_indices.size} unused Opensearch indices for #{model}")
      else
        logging(model, "No unused Opensearch indices were found for #{model} to be deleted")
      end
    end
  end

private

  def logging(model, msg)
    Sidekiq.logger.info "#{model.opensearch_log_tag} #{msg}"
  end
end
