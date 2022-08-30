require "rails_helper"

RSpec.describe OpenSearchQuery::Notification, type: :model do
  let(:fields) { OpenSearchQuery::Notification::FIELDS }
  let(:from_date) { nil }
  let(:to_date)   { nil }
  let(:sort_by)   { nil }
  let(:query) { described_class.new(keyword: q, category: category, from_date: from_date, to_date: to_date, sort_by: sort_by).build_query }

  shared_examples_for "correct query" do
    specify do
      expect(query).to eq expected_es_query
    end
  end

  context "when search term is provided and category filter is empty" do
    it_behaves_like "correct query" do
      let(:q) { "Foo bar" }
      let(:category) { nil }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { multi_match: { fields: fields, fuzziness: "AUTO", query: "Foo bar" } } } }, sort: %w[_score] }
      end
    end
  end

  context "when search term is provided and category filter is not empty" do
    it_behaves_like "correct query" do
      let(:q) { "Foo bar" }
      let(:category) { "Bar baz" }

      let(:expected_es_query) do
        { query: { bool: { filter: [{ nested: { path: "components", query: { bool: { should: [{ term: { "components.display_root_category": "Bar baz" } }] } } } }], must: { multi_match: { fields: fields, fuzziness: "AUTO", query: "Foo bar" } } } }, sort: %w[_score] }
      end
    end
  end

  context "when no search term is provided and category filter is empty" do
    it_behaves_like "correct query" do
      let(:q) { nil }
      let(:category) { nil }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_all: {} } } }, sort: [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "when using date ascending sort" do
    it_behaves_like "correct query" do
      let(:q) { nil }
      let(:category) { nil }
      let(:sort_by) { OpenSearchQuery::Notification::DATE_ASCENDING_SORTING }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_all: {} } } }, sort:  [{ notification_complete_at: { order: :asc } }] }
      end
    end
  end

  context "when using date descending sort" do
    it_behaves_like "correct query" do
      let(:q) { nil }
      let(:category) { nil }
      let(:sort_by) { OpenSearchQuery::Notification::DATE_DESCENDING_SORTING }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_all: {} } } }, sort:  [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "when using empty sort argument" do
    it_behaves_like "correct query" do
      let(:q) { nil }
      let(:category) { nil }
      let(:sort_by) { "" }

      let(:expected_es_query) do
        { query: { bool: { filter: [], must: { match_all: {} } } }, sort: [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "when no search term is provided and category filter is not empty" do
    it_behaves_like "correct query" do
      let(:q) { nil }
      let(:category) { "Bar baz" }

      let(:expected_es_query) do
        { query: { bool: { filter: [{ nested: { path: "components", query: { bool: { should: [{ term: { "components.display_root_category": "Bar baz" } }] } } } }], must: { match_all: {} } } }, sort: [{ notification_complete_at: { order: :desc } }] }
      end
    end
  end

  context "when dates are provided" do
    it_behaves_like "correct query" do
      let(:q) { "Foo bar" }
      let(:category) { "Bar baz" }
      let(:from_date) { Date.new(2021, 6, 6) }
      let(:to_date) { Date.new(2021, 6, 16) }

      let(:expected_es_query) do
        { query: { bool: { filter: [{ nested: { path: "components", query: { bool: { should: [{ term: { "components.display_root_category": "Bar baz" } }] } } } }, { range: { notification_complete_at: { gte: Date.new(2021, 6, 6), lte: Date.new(2021, 6, 16) } } }], must: { multi_match: { fields: fields, fuzziness: "AUTO", query: "Foo bar" } } } }, sort: %w[_score] }
      end
    end
  end
end
