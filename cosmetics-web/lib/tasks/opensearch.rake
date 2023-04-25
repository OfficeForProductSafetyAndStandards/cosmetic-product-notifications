namespace :open_search do
  desc "Reindex OpenSearch"
  task reindex: :environment do
    ReindexOpensearchJob.perform_later
  end
end
