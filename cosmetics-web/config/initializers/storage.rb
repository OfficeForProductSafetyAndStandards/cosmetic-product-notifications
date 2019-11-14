# ActiveStorage does not support multiple analyzers. To get past this, we are setting the analyzers list
# to contain just a MasterAnalyzer. This Analyzer will decide which of the other analyzers to use
# document_analyzers is a list of the analyzers that we will use
Rails.application.config.document_analyzers = Rails.application.config.active_storage.analyzers

if ENV.fetch("ANTIVIRUS_ENABLED", "true") == "true"
  Rails.application.config.document_analyzers.append AntiVirusAnalyzer
end

Rails.application.config.document_analyzers.append ReadDataAnalyzer
# MasterAnalyzer is the only one that we pass to active_storage
Rails.application.config.active_storage.analyzers = [MasterAnalyzer]
Rails.application.config.active_storage.queue = :cosmetics
