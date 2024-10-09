require "rails_helper"

RSpec.describe Types::ResponsiblePersonUserQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "responsible_person_user query" do
    let(:responsible_person_user) { create(:responsible_person_user) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          responsible_person_user(id: $id) {
            id
            created_at
            updated_at
            responsible_person {
              id
              name
            }
            user {
              id
              email
              name
            }
          }
        }
      GQL
    end

    def query_responsible_person_user_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["responsible_person_user"]
    end

    it "returns a ResponsiblePersonUser by ID" do
      data = query_responsible_person_user_and_extract_data(responsible_person_user.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(responsible_person_user.id.to_s)
    end

    it "returns the associated ResponsiblePerson name" do
      data = query_responsible_person_user_and_extract_data(responsible_person_user.id)
      expect(data["responsible_person"]["name"]).to eq(responsible_person_user.responsible_person.name)
    end

    it "returns the associated User email" do
      data = query_responsible_person_user_and_extract_data(responsible_person_user.id)
      expect(data["user"]["email"]).to eq(responsible_person_user.user.email)
    end

    it "returns created_at timestamp" do
      data = query_responsible_person_user_and_extract_data(responsible_person_user.id)
      expect(data["created_at"]).to eq(responsible_person_user.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_responsible_person_user_and_extract_data(responsible_person_user.id)
      expect(data["updated_at"]).to eq(responsible_person_user.updated_at.utc.iso8601)
    end

    it "returns an error when ResponsiblePersonUser not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find responsible_person_user with 'id' -1")
    end
  end

  describe "responsible_person_users query" do
    let!(:recent_responsible_person_user) { create(:responsible_person_user, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_responsible_person_user) { create(:responsible_person_user, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          responsible_person_users(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
                user {
                  id
                  email
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

    def query_responsible_person_users(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of ResponsiblePersonUsers" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "responsible_person_users", "edges").size).to eq(1)
    end

    it "returns the associated name for the first responsible person" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "responsible_person_users", "edges").first["node"]["responsible_person"]["name"]).to eq(recent_responsible_person_user.responsible_person.name)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_users", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_users", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_users", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_responsible_person_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "responsible_person_users", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_responsible_person_users_count query" do
    before do
      create_list(:responsible_person_user, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_responsible_person_users_count
        }
      GQL
    end

    it "returns the total count of ResponsiblePersonUsers" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_responsible_person_users_count"]
      expect(data).to eq(3)
    end
  end
end
