namespace :open_search do
  desc "Reindex Open Search"
  task reindex: :environment do
    ReindexOpensearchJob.perform_now
  end
end
