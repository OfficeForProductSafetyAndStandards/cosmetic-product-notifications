Elasticsearch::Model.client = Elasticsearch::Client.new(Rails.application.config_for(:opensearch))
# bypasses the recently introduced version check to allow ES gems to connect to an Opensearch 1 server
Elasticsearch::Model.client.instance_variable_set("@verified", true)
