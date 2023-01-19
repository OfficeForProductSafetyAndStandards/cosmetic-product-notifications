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
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: %w[_score] }
      end
    end
  end

  context "with group_by filter" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, "_score"] }
      end
    end
  end

  context "with a sort_by score filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::SCORE_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: %w[_score] }
      end
    end
  end

  context "with a sort_by date ascending filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: [{ notification_complete_at: { order: :asc } }] }
      end
    end
  end

  context "with a sort_by date descending filter" do
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "with group_by and sort_by date descending filters" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_DESCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, { notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "with group_by and sort_by date ascending filters" do
    let(:group_by) { OpenSearchQuery::Ingredient::GROUP_BY_RESPONSIBLE_PERSON_ASC }
    let(:sort_by) { OpenSearchQuery::Ingredient::DATE_ASCENDING_SORTING }

    it_behaves_like "correct query" do
      let(:expected_es_query) do
        { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                           filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
          sort: [{ "responsible_person.id" => { order: "asc" } }, { notification_complete_at: { order: :asc } }] }
      end
    end
  end

  describe "date filters" do
    context "without date filters" do
      it "defaults to filter results from the ingredients release date and onwards" do
        expect(query).to eq(
          { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                             filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: nil } } }] } },
            sort: %w[_score] },
        )
      end
    end

    context "with from_date and to_date filters" do
      let(:to_date) { Date.parse("2023-01-12") }

      context "with a from_date posterior to the ingredients release date" do
        let(:from_date) { Date.parse("2022-11-10") }

        it "filters results from the given from date and onwards" do
          expect(query).to eq(
            { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                               filter: [{ range: { notification_complete_at: { gte: "2022-11-10", lte: "2023-01-12" } } }] } },
              sort: %w[_score] },
          )
        end
      end

      context "with a from_date prior to the ingredients release date" do
        let(:from_date) { Date.parse("2021-11-10") }

        it "filters results from the ingredients release date and onwards" do
          expect(query).to eq(
            { query: { bool: { must: { match_phrase: { searchable_ingredients: { query: "sodium" } } },
                               filter: [{ range: { notification_complete_at: { gte: "2022-10-03", lte: "2023-01-12" } } }] } },
              sort: %w[_score] },
          )
        end
      end
    end
  end
end
