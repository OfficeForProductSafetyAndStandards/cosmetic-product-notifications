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

def reindex_opensearch_index_job
  job = Sidekiq::Cron::Job.new(
    name: "Reindex Opensearch, every Saturday at 1 am",
    cron: "1 1 * * sat", # Every Saturday at 1:01 am
    class: "ReindexOpensearchJob",
    queue: "cosmetics",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Opensearch reindexing job was not saved! *****"
    Rails.logger.error job.errors.join("; ")
  end
end

def delete_old_opensearch_indices_job
  job = Sidekiq::Cron::Job.new(
    name: "Delete old Opensearch indices, every Sunday at 1:10 am",
    cron: "10 1 * * sun", # Every Sunday at 1:10 am
    class: "DeleteOldOpensearchIndicesJob",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Delete old Opensearch indices job was not saved! *****"
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

def upload_nanomaterial_notifications_job
  job = Sidekiq::Cron::Job.new(
    name: "Upload a CSV with all Nanomaterial Notifications every day at 00:15",
    cron: "15 0 * * *",
    class: "UploadNanomaterialNotificationsJob",
    queue: "cosmetics",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Upload Nanomaterial Notifications CSV job was not saved! *****"
    Rails.logger.error job.errors.join("; ")
  end
end

def upload_nanomaterials_pdfs_job
  job = Sidekiq::Cron::Job.new(
    name: "Upload a ZIP with all Nanomaterials safety data sheets every day at 00:30",
    cron: "30 0 * * *",
    class: "UploadNanomaterialsPdfsJob",
    queue: "cosmetics",
  )
  unless job.save
    Rails.logger.error "***** WARNING - Upload Nanomaterials PDFs job was not saved! *****"
    Rails.logger.error job.errors.join("; ")
  end
end

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  create_log_db_metrics_job
  delete_old_opensearch_indices_job
  reindex_opensearch_index_job
  upload_cosmetic_products_containing_nanomaterials_job
  upload_nanomaterial_notifications_job
  upload_nanomaterials_pdfs_job

  Sidekiq::Status.configure_server_middleware(config)
  Sidekiq::Status.configure_client_middleware(config)
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)

  Sidekiq::Status.configure_client_middleware(config)
end
