json.extract! business, :id, :company_name, :company_number, :company_type_code,
              :registered_office_address_line_1, :registered_office_address_line_2,
              :registered_office_address_locality, :registered_office_address_country,
              :registered_office_address_postal_code, :nature_of_business_id,
              :additional_information, :created_at, :updated_at
json.url business_url(business, format: :json)
