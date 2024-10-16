require "rails_helper"

RSpec.describe Types::PendingResponsiblePersonUserQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "pending_responsible_person_user query" do
    let(:pending_user) { create(:pending_responsible_person_user) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          pending_responsible_person_user(id: $id) {
            id
            email_address
            created_at
            updated_at
            responsible_person {
              id
              name
            }
            invitation_token
            invitation_token_expires_at
            inviting_user {
              id
              email
              name
            }
            name
          }
        }
      GQL
    end

    def query_pending_user_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["pending_responsible_person_user"]
    end

    it "returns a PendingResponsiblePersonUser by ID" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(pending_user.id.to_s)
    end

    it "returns the associated email_address" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["email_address"]).to eq(pending_user.email_address)
    end

    it "returns created_at timestamp" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["created_at"]).to eq(pending_user.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["updated_at"]).to eq(pending_user.updated_at.utc.iso8601)
    end

    it "returns the associated responsible person details" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["responsible_person"]["id"]).to eq(pending_user.responsible_person.id.to_s)
      expect(data["responsible_person"]["name"]).to eq(pending_user.responsible_person.name)
    end

    it "returns the associated inviting user id" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["inviting_user"]["id"]).to eq(pending_user.inviting_user.id.to_s)
    end

    it "returns the associated inviting user email" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["inviting_user"]["email"]).to eq(pending_user.inviting_user.email)
    end

    it "returns the associated inviting user name" do
      data = query_pending_user_and_extract_data(pending_user.id)
      expect(data["inviting_user"]["name"]).to eq(pending_user.inviting_user.name)
    end

    it "returns an error when PendingResponsiblePersonUser not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find pending_responsible_person_user with 'id' -1")
    end
  end

  describe "pending_responsible_person_users query" do
    let!(:recent_pending_user) { create(:pending_responsible_person_user, created_at: "2024-08-10", updated_at: "2024-08-15") }
    let(:older_pending_user) { create(:pending_responsible_person_user, created_at: "2024-08-01", updated_at: "2024-08-05") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          pending_responsible_person_users(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                email_address
                created_at
                updated_at
                responsible_person {
                  id
                  name
                }
                invitation_token
                invitation_token_expires_at
                inviting_user {
                  id
                  email
                  name
                }
                name
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

    def query_pending_users(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of PendingResponsiblePersonUsers" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "pending_responsible_person_users", "edges").size).to eq(1)
    end

    it "returns the associated email_address for the first user" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "pending_responsible_person_users", "edges").first["node"]["email_address"]).to eq(recent_pending_user.email_address)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "pending_responsible_person_users", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "pending_responsible_person_users", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "pending_responsible_person_users", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_pending_users(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "pending_responsible_person_users", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_pending_responsible_person_users_count query" do
    before do
      create_list(:pending_responsible_person_user, 3)
    end

    let(:query) do
      <<~GQL
        query {
          total_pending_responsible_person_users_count
        }
      GQL
    end

    it "returns the total count of PendingResponsiblePersonUsers" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_pending_responsible_person_users_count"]
      expect(data).to eq(3)
    end
  end
end
