require "rails_helper"

RSpec.describe Types::TriggerQuestionElementQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "trigger_question_element query" do
    let(:trigger_question) { create(:trigger_question) }
    let(:trigger_question_element) { create(:trigger_question_element, trigger_question:, element: "ethanol") }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          trigger_question_element(id: $id) {
            id
            answer_order
            answer
            element_order
            element
            created_at
            updated_at
            trigger_question {
              id
              question
            }
          }
        }
      GQL
    end

    def query_trigger_question_element_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["trigger_question_element"]
    end

    it "returns a TriggerQuestionElement by ID" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(trigger_question_element.id.to_s)
    end

    it "returns the associated answer_order" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data["answer_order"]).to eq(trigger_question_element.answer_order)
    end

    it "returns the associated answer" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data["answer"]).to eq(trigger_question_element.answer)
    end

    it "returns created_at timestamp" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data["created_at"]).to eq(trigger_question_element.created_at.utc.iso8601)
    end

    it "returns updated_at timestamp" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data["updated_at"]).to eq(trigger_question_element.updated_at.utc.iso8601)
    end

    it "returns the associated trigger_question details" do
      data = query_trigger_question_element_and_extract_data(trigger_question_element.id)
      expect(data["trigger_question"]["id"]).to eq(trigger_question_element.trigger_question.id.to_s)
      expect(data["trigger_question"]["question"]).to eq(trigger_question_element.trigger_question.question)
    end

    it "returns an error when TriggerQuestionElement not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find trigger_question_element with 'id' -1")
    end
  end

  describe "trigger_question_elements query" do
    let!(:recent_trigger_question) { create(:trigger_question) }
    let!(:ethanol_trigger_question_element) { create(:trigger_question_element, created_at: "2024-08-10", updated_at: "2024-08-15", trigger_question: recent_trigger_question, element: "ethanol") }
    let!(:propanol_trigger_question_element) { create(:trigger_question_element, created_at: "2024-08-12", updated_at: "2024-08-16", trigger_question: recent_trigger_question, element: "propanol") }

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          trigger_question_elements(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                answer_order
                answer
                element_order
                element
                created_at
                updated_at
                trigger_question {
                  id
                  question
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

    def query_trigger_question_elements(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of TriggerQuestionElements" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "trigger_question_elements", "edges").size).to eq(2)
    end

    it "returns the associated answer for the first element" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      expect(response_json.dig("data", "trigger_question_elements", "edges").first["node"]["answer"]).to eq(ethanol_trigger_question_element.answer)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "trigger_question_elements", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "trigger_question_elements", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "trigger_question_elements", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      page_info = response_json.dig("data", "trigger_question_elements", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end

    it "checks the details of the propanol element" do
      response_json = query_trigger_question_elements(created_after: "2024-08-05T00:00:00Z", first: 10)
      propanol_element_data = response_json.dig("data", "trigger_question_elements", "edges").find do |edge|
        edge["node"]["element"] == "propanol"
      end
      expect(propanol_element_data).not_to be_nil
      expect(propanol_element_data["node"]["id"]).to eq(propanol_trigger_question_element.id.to_s)
    end
  end

  describe "total_trigger_question_elements_count query" do
    before do
      create_list(:trigger_question_element, 3, trigger_question: create(:trigger_question, question: "Some question?"))
    end

    let(:query) do
      <<~GQL
        query {
          total_trigger_question_elements_count
        }
      GQL
    end

    it "returns the total count of TriggerQuestionElements" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_trigger_question_elements_count"]
      expect(data).to eq(3)
    end
  end
end
