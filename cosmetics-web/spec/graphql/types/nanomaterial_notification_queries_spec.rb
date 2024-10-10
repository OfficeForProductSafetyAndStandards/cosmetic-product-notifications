require "rails_helper"

RSpec.describe Types::NanomaterialNotificationQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Method to perform the GraphQL post request
  def perform_post_query(variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "nanomaterial_notification query" do
    let(:nanomaterial_notification) { create(:nanomaterial_notification) }
    let(:query) do
      <<~GQL
        query($id: ID!) {
          nanomaterial_notification(id: $id) {
            id
            name
            created_at
            updated_at
            responsible_person_id
            user_id
            eu_notified
            notified_to_eu_on
            submitted_at
          }
        }
      GQL
    end

    it "returns a NanomaterialNotification by ID" do
      response_json = perform_post_query({ id: nanomaterial_notification.id })

      expect(response_json).to have_key("data")
    end

    it "checks NanomaterialNotification attributes" do
      response_json = perform_post_query({ id: nanomaterial_notification.id })

      data = response_json["data"]["nanomaterial_notification"]

      expect(data["id"]).to eq(nanomaterial_notification.id.to_s)
      expect(data["name"]).to eq(nanomaterial_notification.name)
    end

    it "checks responsible_person_id attribute" do
      response_json = perform_post_query({ id: nanomaterial_notification.id })

      data = response_json["data"]["nanomaterial_notification"]

      expect(data["responsible_person_id"]).to eq(nanomaterial_notification.responsible_person_id.to_s)
    end

    it "returns an error when NanomaterialNotification not found" do
      response_json = perform_post_query({ id: -1 })

      expect(response_json).to have_key("errors")
      expect(response_json["errors"].first["message"]).to eq("Couldn't find nanomaterial_notification with 'id' -1")
    end
  end

  describe "nanomaterial_notifications query" do
    let!(:recent_nanomaterial_notification) { create(:nanomaterial_notification, created_at: "2023-08-10", updated_at: "2023-08-15") }

    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          nanomaterial_notifications(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                name
                created_at
                updated_at
                responsible_person_id
                user_id
                eu_notified
                notified_to_eu_on
                submitted_at
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

    it "returns data key when filtering by created_after" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      expect(response_json).to have_key("data")
    end

    it "returns the correct number of filtered NanomaterialNotifications" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      data = response_json["data"]["nanomaterial_notifications"]["edges"]
      expect(data.size).to eq(1)
    end

    it "returns the correct filtered NanomaterialNotification ID" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      data = response_json["data"]["nanomaterial_notifications"]["edges"]
      expect(data.first["node"]["id"]).to eq(recent_nanomaterial_notification.id.to_s)
    end

    it "returns false for hasNextPage" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["nanomaterial_notifications"]["pageInfo"]
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "returns false for hasPreviousPage" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["nanomaterial_notifications"]["pageInfo"]
      expect(page_info["hasPreviousPage"]).to be(false)
    end

    it "returns non-nil startCursor" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["nanomaterial_notifications"]["pageInfo"]
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "returns non-nil endCursor" do
      response_json = perform_post_query({ created_after: "2023-08-05T00:00:00Z", first: 10 })

      page_info = response_json["data"]["nanomaterial_notifications"]["pageInfo"]
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_nanomaterial_notifications_count query" do
    let(:query) do
      <<~GQL
        query {
          total_nanomaterial_notifications_count
        }
      GQL
    end

    it "returns the total count of NanomaterialNotifications" do
      create_list(:nanomaterial_notification, 3)
      response_json = perform_post_query({})

      data = response_json["data"]["total_nanomaterial_notifications_count"]
      expect(data).to eq(3)
    end
  end
end
