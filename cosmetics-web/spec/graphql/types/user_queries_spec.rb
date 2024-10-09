require "rails_helper"

RSpec.describe Types::UserQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "user query" do
    let(:user) { create(:user) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          user(id: $id) {
            id
            name
            email
            mobile_number
            mobile_number_verified
            created_at
            updated_at
          }
        }
      GQL
    end

    def query_user_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["user"]
    end

    it "returns a User by ID" do
      data = query_user_and_extract_data(user.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(user.id.to_s)
    end

    it "returns the user's name" do
      data = query_user_and_extract_data(user.id)
      expect(data["name"]).to eq(user.name)
    end

    it "returns the user's email" do
      data = query_user_and_extract_data(user.id)
      expect(data["email"]).to eq(user.email)
    end

    it "returns the user's mobile number" do
      data = query_user_and_extract_data(user.id)
      expect(data["mobile_number"]).to eq(user.mobile_number)
    end

    it "returns the mobile number verification status" do
      data = query_user_and_extract_data(user.id)
      expect(data["mobile_number_verified"]).to eq(user.mobile_number_verified)
    end

    it "returns created_at timestamp" do
      data = query_user_and_extract_data(user.id)
      expect(data["created_at"]).to eq(user.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_user_and_extract_data(user.id)
      expect(data["updated_at"]).to eq(user.updated_at.utc.iso8601)
    end

    it "returns an error when User not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find user with 'id' -1")
    end
  end

  describe "users query" do
    let!(:recent_user_created_later) { create(:user, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:recent_user_created_earlier) { create(:user, created_at: "2024-08-12", updated_at: "2024-08-16") }
    let(:older_user) { create(:user, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          users(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                name
                email
                created_at
                updated_at
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

    def query_users(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of Users" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "users", "edges").size).to eq(1)
    end

    it "returns the associated name for the first user" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "users", "edges").first["node"]["name"]).to eq(recent_user_created_later.name)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "users", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "users", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "users", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "users", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_users_count query" do
    before do
      create_list(:user, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_users_count
        }
      GQL
    end

    it "returns the total count of Users" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_users_count"]
      expect(data).to eq(3)
    end
  end
end
