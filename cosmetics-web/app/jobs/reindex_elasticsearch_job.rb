class ReindexElasticsearchJob < ApplicationJob
  def perform
    total = 0
    ActiveRecord::Base.descendants.each do |model|
      next unless model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)

      total += 1
      if model.respond_to?(:elasticsearch)
        model.elasticsearch.import force: true
      else
        model.import force: true
      end
    end

    Sidekiq.logger.info "Imported #{total} records to Elasticsearch"
  end
end
