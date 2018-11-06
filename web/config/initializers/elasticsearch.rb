Elasticsearch::Model.client = Elasticsearch::Client.new(Rails.application.config_for(:elasticsearch))
