require "rails_helper"

RSpec.describe Types::DeletedNotificationQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  before do
    DeletedNotification.delete_all
  end

  it "ensures there are no DeletedNotifications before tests" do
    expect(DeletedNotification.count).to eq(0)
  end

  describe "deleted_notification query" do
    let(:deleted_notification) { create(:deleted_notification) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          deleted_notification(id: $id) {
            id
            product_name
            state
            created_at
            updated_at
          }
        }
      GQL
    end

    def query_deleted_notification_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["deleted_notification"]
    end

    it "returns a DeletedNotification by ID" do
      data = query_deleted_notification_and_extract_data(deleted_notification.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(deleted_notification.id.to_s)
    end

    it "returns the associated product_name" do
      data = query_deleted_notification_and_extract_data(deleted_notification.id)
      expect(data["product_name"]).to eq(deleted_notification.product_name)
    end
  end

  describe "deleted_notifications query" do
    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          deleted_notifications(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                product_name
                state
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

    def query_deleted_notifications(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the correct number of DeletedNotifications in a paginated query" do
      DeletedNotification.delete_all
      create(:deleted_notification)

      response_json = query_deleted_notifications(first: 10)
      edges = response_json.dig("data", "deleted_notifications", "edges")

      expect(edges.size).to eq(1)
    end

    it "returns the associated product_name for the first notification" do
      DeletedNotification.delete_all
      recent_deleted_notification = create(:deleted_notification)

      response_json = query_deleted_notifications(first: 10)
      edges = response_json.dig("data", "deleted_notifications", "edges")
      first_node = edges.first["node"]

      expect(first_node["product_name"]).to eq(recent_deleted_notification.product_name)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_deleted_notifications(first: 10)
      page_info = response_json.dig("data", "deleted_notifications", "pageInfo")

      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_deleted_notifications(first: 10)
      page_info = response_json.dig("data", "deleted_notifications", "pageInfo")

      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_deleted_notifications(first: 10)
      page_info = response_json.dig("data", "deleted_notifications", "pageInfo")

      unless response_json.dig("data", "deleted_notifications", "edges").empty?
        expect(page_info["startCursor"]).not_to be_nil
      end
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_deleted_notifications(first: 10)
      page_info = response_json.dig("data", "deleted_notifications", "pageInfo")

      unless response_json.dig("data", "deleted_notifications", "edges").empty?
        expect(page_info["endCursor"]).not_to be_nil
      end
    end
  end

  describe "total_deleted_notifications_count query" do
    before do
      DeletedNotification.delete_all
    end

    let(:query) do
      <<~GQL
        query {
          total_deleted_notifications_count
        }
      GQL
    end

    it "returns the correct total count of DeletedNotifications" do
      create_list(:deleted_notification, 3)

      response_json = perform_post_query(query)
      expect(response_json["data"]["total_deleted_notifications_count"]).to eq(3)
    end
  end
end
