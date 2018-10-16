json.extract! activity, :id, :investigation_id, :activity_type, :notes, :created_at, :updated_at
json.url activity_url(activity, format: :json)
