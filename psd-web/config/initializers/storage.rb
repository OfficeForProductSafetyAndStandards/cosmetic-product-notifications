# ActiveStorage does not support multiple analyzers. To get past this, we are setting the analyzers list
# to contain just a MasterAnalyzer. This Analyzer will decide which of the other analyzers to use
# document_analyzers is a list of the analyzers that we will use
Rails.application.config.document_analyzers = Rails.application.config.active_storage.analyzers
Rails.application.config.document_analyzers.append Shared::Web::AntiVirusAnalyzer
# MasterAnalyzer is the only one that we pass to active_storage
Rails.application.config.active_storage.analyzers = [Shared::Web::MasterAnalyzer]
Rails.application.config.active_storage.queue = :psd
