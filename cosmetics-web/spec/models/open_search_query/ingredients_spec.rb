require "rails_helper"

RSpec.describe OpenSearchQuery::Ingredient, type: :model do
  let(:q)          { "sodium" }
  let(:match_type) { OpenSearchQuery::Ingredient::EXACT_MATCH }
  let(:from_date)  { nil }
  let(:to_date)    { nil }
  let(:sort_by)    { nil }

  let(:query) { described_class.new(keyword: q, match_type: match_type, from_date: from_date, to_date: to_date, sort_by: sort_by).build_query }

  shared_examples_for "correct query" do
    specify do
      expect(query).to eq expected_es_query
    end
  end

  context "when using simple search" do
    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } }, filter: [] } } }
      end
    end
  end

  context "with sort_by filter" do
    it_behaves_like "correct query" do
      let(:sort_by) { OpenSearchQuery::Ingredient::SORT_BY_RESPONSIBLE_PERSON_ASC }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } }, sort: [{ "responsible_person.id" => { order: "asc" } }] }
      end
    end
  end
end
