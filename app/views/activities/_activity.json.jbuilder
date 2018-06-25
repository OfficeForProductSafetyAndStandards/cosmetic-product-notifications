json.extract! activity, :id, :investigation_id, :activity_type_id, :notes, :created_at, :updated_at
json.url activity_url(activity, format: :json)
