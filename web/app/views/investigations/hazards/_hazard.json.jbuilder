json.extract! hazard, :id, :hazard_type, :description, :affected_parties, :risk_level, :investigation, :created_at, :updated_at
json.url hazard_url(hazard, format: :json)
