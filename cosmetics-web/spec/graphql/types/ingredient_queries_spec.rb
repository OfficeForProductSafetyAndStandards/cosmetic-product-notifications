require "rails_helper"

RSpec.describe Types::IngredientQueries, type: :request do
  let(:api_key) { ApiKey.create_with_generated_key(team: "Test Team").key }
  let(:headers) { { 'X-API-KEY': api_key } }

  # Helper method to perform the GraphQL post request
  def perform_post_query(query, variables = {})
    post("http://cosmetics-submit:3000/graphql", params: { query:, variables: variables.to_json }, headers:)
    JSON.parse(response.body)
  end

  describe "ingredient query" do
    let(:ingredient) { create(:ingredient, exact_concentration: 2.5) }

    let(:query) do
      <<~GQL
        query($id: ID!) {
          ingredient(id: $id) {
            id
            inci_name
            cas_number
            exact_concentration
            range_concentration
            poisonous
            used_for_multiple_shades
            minimum_concentration
            maximum_concentration
            created_at
            updated_at
          }
        }
      GQL
    end

    it "returns an Ingredient ID" do
      response_json = perform_post_query(query, { id: ingredient.id })

      expect(response_json).to have_key("data")
      data = response_json["data"]["ingredient"]

      expect(data["id"]).to eq(ingredient.id.to_s)
    end

    it "returns an Ingredient's INCI name" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["inci_name"]).to eq(ingredient.inci_name)
    end

    it "returns an Ingredient's CAS number" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["cas_number"]).to eq(ingredient.cas_number)
    end

    it "returns an Ingredient's exact concentration" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["exact_concentration"]).to eq(ingredient.exact_concentration)
    end

    it "returns whether the Ingredient is poisonous" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["poisonous"]).to eq(ingredient.poisonous)
    end

    it "returns nil for minimum concentration when it's an exact concentration" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["minimum_concentration"]).to be_nil
    end

    it "returns nil for maximum concentration when it's an exact concentration" do
      response_json = perform_post_query(query, { id: ingredient.id })

      data = response_json["data"]["ingredient"]
      expect(data["maximum_concentration"]).to be_nil
    end

    it "returns an error when Ingredient not found" do
      response_json = perform_post_query(query, { id: -1 })

      expect(response_json).to have_key("errors")
      errors = response_json["errors"]

      expect(errors.first["message"]).to eq("Couldn't find ingredient with 'id' -1")
    end
  end

  describe "ingredients query" do
    let(:exact_ingredient) { create(:ingredient, :exact, created_at: "2023-08-01", updated_at: "2023-08-05") }
    let!(:range_ingredient) { create(:ingredient, :range, created_at: "2023-08-10", updated_at: "2023-08-15") }

    let(:query) do
      <<~GQL
        query($created_after: String, $first: Int) {
          ingredients(created_after: $created_after, first: $first) {
            edges {
              node {
                id
                inci_name
                cas_number
                exact_concentration
                range_concentration
                poisonous
                minimum_concentration
                maximum_concentration
                created_at
                updated_at
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

    context "when filtering by creation date" do
      let(:params) { { created_after: "2023-08-05T00:00:00Z", first: 10 } }
      let(:response_json) { perform_post_query(query, params) }

      it "returns a list of Ingredients" do
        expect(response_json).to have_key("data")
      end

      it "returns the correct number of Ingredients" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.size).to eq(1)
      end

      it "returns the correct Ingredient ID" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.first["node"]["id"]).to eq(range_ingredient.id.to_s)
      end

      it "returns the correct INCI name" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.first["node"]["inci_name"]).to eq(range_ingredient.inci_name)
      end

      it "returns the correct CAS number" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.first["node"]["cas_number"]).to eq(range_ingredient.cas_number)
      end

      it "returns the correct minimum concentration" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.first["node"]["minimum_concentration"]).to eq(range_ingredient.minimum_concentration)
      end

      it "returns the correct maximum concentration" do
        data = response_json["data"]["ingredients"]["edges"]
        expect(data.first["node"]["maximum_concentration"]).to eq(range_ingredient.maximum_concentration)
      end

      it "checks if pagination info is present" do
        page_info = response_json["data"]["ingredients"]["pageInfo"]
        expect(page_info).to have_key("hasNextPage")
        expect(page_info).to have_key("hasPreviousPage")
      end

      it "checks hasNextPage value" do
        page_info = response_json["data"]["ingredients"]["pageInfo"]
        expect(page_info["hasNextPage"]).to be(false)
      end

      it "checks hasPreviousPage value" do
        page_info = response_json["data"]["ingredients"]["pageInfo"]
        expect(page_info["hasPreviousPage"]).to be(false)
      end

      it "checks startCursor value" do
        page_info = response_json["data"]["ingredients"]["pageInfo"]
        expect(page_info["startCursor"]).not_to be_nil
      end

      it "checks endCursor value" do
        page_info = response_json["data"]["ingredients"]["pageInfo"]
        expect(page_info["endCursor"]).not_to be_nil
      end
    end
  end

  describe "total_ingredients_count query" do
    before { Ingredient.delete_all }

    let(:query) do
      <<~GQL
        query {
          total_ingredients_count
        }
      GQL
    end

    it "returns the total count of Ingredients" do
      create_list(:ingredient, 3, exact_concentration: 2.5)
      response_json = perform_post_query(query)

      expect(response_json).to have_key("data")
      data = response_json["data"]["total_ingredients_count"]

      expect(data).to eq(3)
    end

    it "returns zero when there are no Ingredients" do
      response_json = perform_post_query(query)

      expect(response_json).to have_key("data")
      data = response_json["data"]["total_ingredients_count"]

      expect(data).to eq(0)
    end
  end
end
