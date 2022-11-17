require "rails_helper"

RSpec.describe OpenSearchQuery::Ingredient, type: :model do
  let(:q)          { "sodium" }
  let(:match_type) { OpenSearchQuery::Ingredient::EXACT_MATCH }
  let(:from_date)  { nil }
  let(:to_date)    { nil }
  let(:group_by)   { nil }
  let(:sort_by)    { nil }

  let(:query) { described_class.new(keyword: q, match_type:, from_date:, to_date:, group_by:, sort_by:).build_query }

  shared_examples_for "correct query" do
    specify do
      expect(query).to eq expected_es_query
    end
  end

  context "when using simple search" do
    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } }, filter: [] } },
          sort: %w[_score] }
      end
    end
  end

  context "with group_by filter" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, "_score"] }
      end
    end
  end

  context "with a sort_by score filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::SCORE_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: %w[_score] }
      end
    end
  end

  context "with a sort_by date ascending filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: [{ notification_complete_at: { order: :asc } }] }
      end
    end
  end

  context "with a sort_by date descending filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "with group_by and sort_by date descending filters" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, { notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "with group_by and sort_by date ascending filters" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_phrase: { searchable_ingredients: { query: "sodium" } } } } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, { notification_complete_at: { order: :asc } }] }
      end
    end
  end
end
