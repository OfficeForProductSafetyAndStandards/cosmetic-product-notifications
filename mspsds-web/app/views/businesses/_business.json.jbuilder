json.extract! business, :id, :legal_name, :trading_name, :company_number, :company_type_code, :company_status_code,
              :nature_of_business_id, :created_at, :updated_at
json.url business_url(business, format: :json)
