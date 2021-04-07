class ReindexElasticsearchJob < ApplicationJob
  def perform
    total = 0
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)
        if model.respond_to?(:elasticsearch)
          total += 1
          model.elasticsearch.import force: true
        else
          total += 1
          model.import force: true
        end
      end
    end

    Sidekiq.logger.info "Imported #{total} records to Elasticsearch"
  end
end
