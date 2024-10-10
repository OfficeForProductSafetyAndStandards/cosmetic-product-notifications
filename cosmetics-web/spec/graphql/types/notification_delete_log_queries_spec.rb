require "rails_helper"

RSpec.describe Types::NotificationDeleteLogQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }
  let(:notification_delete_log) { create(:notification_delete_log) }

  # Method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "notification_delete_log query" do
    let(:query) do
      <<~GQL
        query($id: ID!) {
          notification_delete_log(id: $id) {
            id
            notification_product_name
            responsible_person_id
            reference_number
          }
        }
      GQL
    end

    it "returns the notification_delete_log ID" do
      response_json = perform_post_query(query, { id: notification_delete_log.id })
      data = response_json["data"]["notification_delete_log"]

      expect(data["id"]).to eq(notification_delete_log.id.to_s)
    end

    it "returns the notification_delete_log product name" do
      response_json = perform_post_query(query, { id: notification_delete_log.id })
      data = response_json["data"]["notification_delete_log"]

      expect(data["notification_product_name"]).to eq(notification_delete_log.notification_product_name)
    end

    it "returns the notification_delete_log responsible_person_id" do
      response_json = perform_post_query(query, { id: notification_delete_log.id })
      data = response_json["data"]["notification_delete_log"]

      expect(data["responsible_person_id"]).to eq(notification_delete_log.responsible_person_id.to_s)
    end

    it "returns an error when the notification_delete_log is not found" do
      response_json = perform_post_query(query, { id: -1 })

      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find notification_delete_log with 'id' -1")
    end
  end

  describe "notification_delete_logs query" do
    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          notification_delete_logs(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                notification_product_name
              }
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

    it "returns a single NotificationDeleteLog filtered by created_after" do
      new_log = create(:notification_delete_log, created_at: "2023-08-10", updated_at: "2023-08-15")
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })

      data = response_json["data"]["notification_delete_logs"]["edges"]
      expect(data.size).to eq(1)
      expect(data.first["node"]["id"]).to eq(new_log.id.to_s)
    end

    it "returns empty edges when no logs match created_after filter" do
      response_json = perform_post_query(query, { created_after: "2023-09-01T00:00:00Z", first: 10 })

      data = response_json["data"]["notification_delete_logs"]["edges"]
      expect(data).to be_empty
    end

    it "returns hasNextPage as false" do
      create(:notification_delete_log, created_at: "2023-08-10", updated_at: "2023-08-15")
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["notification_delete_logs"]["pageInfo"]
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "returns hasPreviousPage as false" do
      create(:notification_delete_log, created_at: "2023-08-10", updated_at: "2023-08-15")
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["notification_delete_logs"]["pageInfo"]
      expect(page_info["hasPreviousPage"]).to be(false)
    end

    it "returns non-nil startCursor" do
      create(:notification_delete_log, created_at: "2023-08-10", updated_at: "2023-08-15")
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["notification_delete_logs"]["pageInfo"]
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "returns non-nil endCursor" do
      create(:notification_delete_log, created_at: "2023-08-10", updated_at: "2023-08-15")
      response_json = perform_post_query(query, { created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["notification_delete_logs"]["pageInfo"]
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_notification_delete_logs_count query" do
    let(:count_query) do
      <<~GQL
        query {
          total_notification_delete_logs_count
        }
      GQL
    end

    it "returns the total count of NotificationDeleteLogs" do
      create_list(:notification_delete_log, 3)
      response_json = perform_post_query(count_query)

      data = response_json["data"]["total_notification_delete_logs_count"]
      expect(data).to eq(3)
    end

    it "returns zero when there are no NotificationDeleteLogs" do
      response_json = perform_post_query(count_query)

      data = response_json["data"]["total_notification_delete_logs_count"]
      expect(data).to eq(0)
    end
  end
end
