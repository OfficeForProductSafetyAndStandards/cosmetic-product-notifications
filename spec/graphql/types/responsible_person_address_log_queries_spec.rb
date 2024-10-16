require "rails_helper"

RSpec.describe Types::ResponsiblePersonAddressLogQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "responsible_person_address_log query" do
    let(:address_log) { create(:responsible_person_address_log) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          responsible_person_address_log(id: $id) {
            id
            line_1
            line_2
            city
            county
            postal_code
            start_date
            end_date
            created_at
            updated_at
            responsible_person {
              id
              name
            }
          }
        }
      GQL
    end

    def query_address_log_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["responsible_person_address_log"]
    end

    it "returns a ResponsiblePersonAddressLog by ID" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(address_log.id.to_s)
    end

    it "returns the associated line_1" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data["line_1"]).to eq(address_log.line_1)
    end

    it "returns the associated city" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data["city"]).to eq(address_log.city)
    end

    it "returns created_at timestamp" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data["created_at"]).to eq(address_log.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data["updated_at"]).to eq(address_log.updated_at.utc.iso8601)
    end

    it "returns the associated responsible person details" do
      data = query_address_log_and_extract_data(address_log.id)
      expect(data["responsible_person"]["id"]).to eq(address_log.responsible_person.id.to_s)
      expect(data["responsible_person"]["name"]).to eq(address_log.responsible_person.name)
    end

    it "returns an error when ResponsiblePersonAddressLog not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find responsible_person_address_log with 'id' -1")
    end
  end

  describe "responsible_person_address_logs query" do
    let!(:recent_address_log) { create(:responsible_person_address_log, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_address_log) { create(:responsible_person_address_log, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          responsible_person_address_logs(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                line_1
                line_2
                city
                county
                postal_code
                start_date
                end_date
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
      GQL
    end

    def query_address_logs(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of ResponsiblePersonAddressLogs" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "responsible_person_address_logs", "edges").size).to eq(1)
    end

    it "returns the associated line_1 for the first log" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "responsible_person_address_logs", "edges").first["node"]["line_1"]).to eq(recent_address_log.line_1)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_address_logs", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_address_logs", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_address_logs", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_address_logs(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_address_logs", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_responsible_person_address_logs_count query" do
    before do
      create_list(:responsible_person_address_log, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_responsible_person_address_logs_count
        }
      GQL
    end

    it "returns the total count of ResponsiblePersonAddressLogs" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_responsible_person_address_logs_count"]
      expect(data).to eq(3)
    end
  end
end
