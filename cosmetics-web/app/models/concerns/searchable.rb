module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # The following dynamic templates define custom mappings for the major data types
    # that automatically generate appropriate sort fields for each type.
    settings do
      mapping dynamic_templates: [
        {
          strings: {
            match_mapping_type: "string",
            mapping: {
              type: "text",
            },
          },
        },
        {
          numbers: {
            match_mapping_type: "long",
            mapping: {
              "type": "long",
              fields: {
                sort: {
                  type: "long",
                },
              },
            },
          },
        },
        {
          dates: {
            match_mapping_type: "date",
            mapping: {
              type: "date",
              fields: {
                sort: {
                  type: "date",
                },
              },
            },
          },
        },
        {
          booleans: {
            match_mapping_type: "boolean",
            mapping: {
              type: "boolean",
              fields: {
                sort: {
                  type: "boolean",
                },
              },
            },
          },
        },
      ]
    end
  end

  class_methods do
    def full_search(query)
      # This line makes sure opensearch index is recreated before we search
      # It fixes the issue of getting no results the first time product list page is loaded
      # It's only used in dev because it lowers performance and the issue it fixes should be an edge case in production
      if Rails.env.development? || Rails.env.test?
        current_index = (current_index_name.presence || create_new_index_with_alias!) # Uses existing or creates/alias new index
        __elasticsearch__.refresh_index! index: current_index
      end
      __elasticsearch__.search(query.build_query)
    end

    # Wraps the Elasticsearch::Model.import method to ensure that set aliases to new index when forcing a new index to
    # be created during the import.
    def import_to_opensearch(force: false)
      existing_index = current_index_name

      index =
        if existing_index.present? && force
          __elasticsearch__.delete_index!(index: existing_index)
          create_new_index_with_alias!
        else
          existing_index.presence || create_new_index_with_alias!
        end

      import(index:, scope: "opensearch", refresh: true)
    end

    # Creates a new index version and sets the model alias pointing to it.
    # Returns the new index version name.
    def create_new_index_with_alias!
      create_new_index!.tap do |name|
        alias_index!(name)
      end
    end

    # Creates a new index. Name will be based on the model alias and timestamped.
    # Returns the new index name.
    def create_new_index!
      name = generate_new_index_name
      __elasticsearch__.create_index!(index: name, force: true)
      name
    end

    # Adds the given index to the model alias.
    # The alias name is the 'index_name' declaration in the model.
    def alias_index!(index)
      __elasticsearch__.client.indices.put_alias(index:, name: index_name)
    end

    def current_index_name
      indices_client = __elasticsearch__.client.indices
      # If there is an index associated to the model alias name
      if indices_client.exists_alias?(name: index_name)
        indices_client.get_alias(name: index_name).keys.first
      # If there is an index created using the index alias name.
      elsif indices_client.exists?(index: index_name)
        index_name
      end
    end

    # Generates a new version of the index name, using the alias name as a base and appending the current datetime.
    # EG: Alias is called "foobar_index", the new index name will be "foobar_index_20221205164343
    def generate_new_index_name
      "#{index_name}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}"
    end

    # Returns the number of documents in the provided/current index.
    def index_docs_count(index = current_index_name)
      return if index.blank?

      __elasticsearch__.client.count(index:)["count"]
    end

    # Model index alias stop pointing to from/current index and starts pointing to the "to:" index without downtime.
    def swap_index_alias!(to:, from: current_index_name)
      indices_client = __elasticsearch__.client.indices

      if indices_client.exists_alias?(name: index_name)
        indices_client.update_aliases body: {
          actions: [
            { remove: { index: from, alias: index_name } },
            { add:    { index: to, alias: index_name } },
          ],
        }
      else # If the alias does not exist, create it.
        alias_index!(to)
      end
    end
  end
end
