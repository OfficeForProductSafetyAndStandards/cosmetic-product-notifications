def create_log_db_metrics_job
  log_db_metrics_job = Sidekiq::Cron::Job.new(
    name: "log db metrics",
    cron: "*/15 * * * *",
    class: "LogDbMetricsJob",
    queue: "cosmetics",
  )
  unless log_db_metrics_job.save
    Rails.logger.error "***** WARNING - Log DB metrics job was not saved! *****"
    Rails.logger.error log_db_metrics_job.errors.join("; ")
  end
end

def create_opensearch_index_job
  job = Sidekiq::Cron::Job.new(
    name: "Reindex Elasticsearch, every day at 1 am",
    cron: "1 1 * * *",
    class: "ReindexOpensearchJob",
    queue: "cosmetics",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Elasticsearch reindexing job was not saved! *****"
    Rails.logger.error job.errors.join("; ")
  end
end

def upload_cosmetic_products_containing_nanomaterials_job
  job = Sidekiq::Cron::Job.new(
    name: "Upload a CSV with all Cosmetic products containing nanomaterials every day at midnight",
    cron: "0 0 * * *",
    class: "UploadCosmeticProductsContainingNanomaterialsJob",
    queue: "cosmetics",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Upload Cosmetics Products Containing Nanomaterials CSV job was not saved! *****"
    Rails.logger.error job.errors.join("; ")
  end
end

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  create_log_db_metrics_job
  create_opensearch_index_job
  upload_cosmetic_products_containing_nanomaterials_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end
