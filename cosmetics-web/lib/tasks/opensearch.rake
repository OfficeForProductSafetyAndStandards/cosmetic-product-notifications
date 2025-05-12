namespace :open_search do
  desc "Reindex OpenSearch"
  task reindex: :environment do
    ReindexOpensearchJob.perform_later
  end

  desc "Check for large documents that might cause circuit breaker issues"
  task check_document_sizes: :environment do
    CheckDocumentSizesJob.perform_later
  end
end
