json.extract! business, :id, :company_name, :company_number, :company_type_code,
              :nature_of_business_id, :additional_information, :created_at, :updated_at
json.url business_url(business, format: :json)
