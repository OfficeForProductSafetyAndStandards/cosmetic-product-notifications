require "rails_helper"

RSpec.describe Types::TriggerQuestionQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "trigger_question query" do
    let(:component) { create(:component) }
    let(:trigger_question) { create(:trigger_question, component:) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          trigger_question(id: $id) {
            id
            question
            applicable
            created_at
            updated_at
            component {
              id
              name
            }
            trigger_question_elements {
              id
              answer_order
              answer
              element_order
              element
            }
          }
        }
      GQL
    end

    def query_trigger_question_and_extract_data(id)
      response_json = perform_post_query(query, { id: })
      response_json["data"]["trigger_question"]
    end

    it "returns a TriggerQuestion by ID" do
      data = query_trigger_question_and_extract_data(trigger_question.id)
      expect(data).to have_key("id")
      expect(data["id"]).to eq(trigger_question.id.to_s)
    end

    it "returns the question text" do
      data = query_trigger_question_and_extract_data(trigger_question.id)
      expect(data["question"]).to eq(trigger_question.question)
    end

    it "returns the applicable status" do
      data = query_trigger_question_and_extract_data(trigger_question.id)
      expect(data["applicable"]).to eq(trigger_question.applicable)
    end

    it "returns the associated component details" do
      data = query_trigger_question_and_extract_data(trigger_question.id)
      expect(data["component"]["id"]).to eq(component.id.to_s)
      expect(data["component"]["name"]).to eq(component.name)
    end

    it "returns trigger question elements" do
      element = create(:trigger_question_element, trigger_question:)
      data = query_trigger_question_and_extract_data(trigger_question.id)
      expect(data["trigger_question_elements"].first["id"]).to eq(element.id.to_s)
    end

    it "returns an error when TriggerQuestion not found" do
      response_json = perform_post_query(query, { id: -1 })
      expect(response_json).to have_key("errors")
      errors = response_json["errors"]
      expect(errors.first["message"]).to eq("Couldn't find trigger_question with 'id' -1")
    end
  end

  describe "trigger_questions query" do
    before do
      create(:trigger_question, created_at: "2024-08-10", updated_at: "2024-08-15", component: create(:component))
      create(:trigger_question, created_at: "2024-08-12", updated_at: "2024-08-16", component: create(:component))
      create(:trigger_question, created_at: "2024-08-01", updated_at: "2024-08-05", component: create(:component))
    end

    let(:query) do
      <<~GQL
        query($created_after: String, $updated_after: String, $first: Int) {
          trigger_questions(created_after: $created_after, updated_after: $updated_after, first: $first) {
            edges {
              node {
                id
                question
                applicable
                created_at
                updated_at
                component {
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

    def query_trigger_questions(created_after: nil, updated_after: nil, first: nil)
      perform_post_query(query, { created_after:, updated_after:, first: })
    end

    it "returns the total number of TriggerQuestions" do
      response_json = query_trigger_questions(first: 10)
      expect(response_json.dig("data", "trigger_questions", "edges").size).to eq(3)
    end

    it "returns the associated question for the first trigger question" do
      response_json = query_trigger_questions(first: 10)
      expect(response_json.dig("data", "trigger_questions", "edges").first["node"]["question"]).to be_a(String)
    end

    it "checks pagination hasNextPage is false" do
      response_json = query_trigger_questions(first: 10)
      page_info = response_json.dig("data", "trigger_questions", "pageInfo")
      expect(page_info["hasNextPage"]).to be(false)
    end

    it "checks pagination hasPreviousPage is false or nil" do
      response_json = query_trigger_questions(first: 10)
      page_info = response_json.dig("data", "trigger_questions", "pageInfo")
      expect(page_info["hasPreviousPage"]).to be(false).or(be_nil)
    end

    it "checks pagination startCursor is not nil" do
      response_json = query_trigger_questions(first: 10)
      page_info = response_json.dig("data", "trigger_questions", "pageInfo")
      expect(page_info["startCursor"]).not_to be_nil
    end

    it "checks pagination endCursor is not nil" do
      response_json = query_trigger_questions(first: 10)
      page_info = response_json.dig("data", "trigger_questions", "pageInfo")
      expect(page_info["endCursor"]).not_to be_nil
    end
  end

  describe "total_trigger_questions_count query" do
    before do
      create_list(:trigger_question, 3, component: create(:component))
    end

    let(:query) do
      <<~GQL
        query {
          total_trigger_questions_count
        }
      GQL
    end

    it "returns the total count of TriggerQuestions" do
      response_json = perform_post_query(query)
      expect(response_json).to have_key("data")
      data = response_json["data"]["total_trigger_questions_count"]
      expect(data).to eq(3)
    end
  end
end
