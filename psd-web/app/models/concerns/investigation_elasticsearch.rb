# rubocop:disable Metrics/BlockLength
module InvestigationElasticsearch
  extend ActiveSupport::Concern
  included do
    include Searchable
    # Elasticsearch index name must be declared in children and parent
    index_name [Rails.env, "investigations"].join("_")

    settings do
      mappings do
        indexes :status, type: :keyword
        indexes :assignable_id, type: :keyword
      end
    end

    def as_indexed_json(*)
      as_json(
        only: %i[description hazard_type product_category is_closed assignable_id updated_at created_at pretty_id
                 hazard_description non_compliant_reason],
        methods: %i[title],
        include: {
          documents: {
            only: [],
            methods: %i[title description filename]
          },
          correspondences: {
            only: %i[correspondent_name details email_address email_subject overview phone_number email_subject]
          },
          activities: {
            methods: :search_index,
            only: []
          },
          businesses: {
            only: %i[legal_name trading_name company_number]
          },
          products: {
            only: %i[category description name product_code product_type]
          },
          complainant: {
            only: %i[name phone_number email_address other_details]
          },
          tests: {
            only: %i[details result legislation]
          },
          corrective_actions: {
            only: %i[details summary legislation]
          },
          alerts: {
            only: %i[description summary]
          }
        }
      )
    end

    def self.highlighted_fields
      %w[*.* pretty_id title description hazard_type product_category hazard_description non_compliant_reason]
    end

    def self.fuzzy_fields
      %w[documents.* correspondences.* activities.* businesses.* products.* complainant.* corrective_actions.*
         tests.* alerts.* title description hazard_type product_category hazard_description non_compliant_reason]
    end

    def self.exact_fields
      %w[pretty_id]
    end
  end
end
# rubocop:enable Metrics/BlockLength
