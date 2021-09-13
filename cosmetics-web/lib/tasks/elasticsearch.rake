namespace :elastic_search do
  desc "Reindex Elastic Search"
  task reindex: :environment do
    ReindexElasticsearchJob.perform_now
  end
end
