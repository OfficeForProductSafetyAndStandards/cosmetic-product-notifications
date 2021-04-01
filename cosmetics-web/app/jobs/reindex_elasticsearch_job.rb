class ReindexElasticsearchJob < ApplicationJob
  def perform
    ActiveRecord::Base.descendants.each do |model|
      if model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)
        if model.respond_to?(:elasticsearch)
          model.elasticsearch.import force: true
        else
          model.import force: true
        end
      end
    end
  end
end
