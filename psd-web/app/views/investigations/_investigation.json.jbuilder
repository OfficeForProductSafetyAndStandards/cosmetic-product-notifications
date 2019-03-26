json.extract! investigation, :id, :description, :is_closed, :source, :risk_overview,
              :product_id, :created_at, :updated_at
json.url investigation_url(investigation, format: :json)
