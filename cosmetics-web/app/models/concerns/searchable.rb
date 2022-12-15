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

  def index_document
    result = __elasticsearch__.index_document

    self.class.searchable_log "#{self.class} with id=#{id} indexed with result #{result}"
  end

  def delete_document_from_index
    result = __elasticsearch__.delete_document

    self.class.searchable_log "#{self.class} with id=#{id} deleted from index with result #{result}"
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    self.class.searchable_log "Failed to delete #{self.class} with id=#{id}. Reason: Not found in index"
  end

  class_methods do
    def full_search(query)
      # This line makes sure opensearch index is recreated before we search
      # It fixes the issue of getting no results the first time product list page is loaded
      # It's only used in dev because it lowers performance and the issue it fixes should be an edge case in production
      if Rails.env.development? || Rails.env.test?
        index = (current_index.presence || create_aliased_index!)
        __elasticsearch__.refresh_index! index:
      end
      __elasticsearch__.search(query.build_query)
    end

    # Wraps the Elasticsearch::Model.import method to ensure that set aliases to new index when forcing a new index to
    # be created during the import.
    def import_to_opensearch(force: false)
      existing_index = current_index # Stored in var to avoid further HTTP calls to OpenSearch

      index =
        if existing_index.present? && force
          __elasticsearch__.delete_index!(index: existing_index)
          searchable_log "Deleted Opensearch index #{existing_index} for #{name}"
          create_aliased_index!
        else
          existing_index.presence || create_aliased_index!
        end

      import(index:, scope: "opensearch", refresh: true).tap do |errors_count|
        if errors_count.zero?
          searchable_log "Imported #{index_docs_count(index)} records for #{name} to Opensearch #{index} index"
        else
          searchable_log "Got #{errors_count} errors while importing #{name} records to Opensearch #{index} index"
        end
      end
    end

    # Creates a new index version and sets the model alias pointing to it.
    # Returns the new index version name.
    def create_aliased_index!
      create_index!.tap do |index|
        alias_index!(index)
      end
    end

    # Creates a new index. Name will be based on the model alias and timestamped.
    # Returns the new index name.
    def create_index!
      index = generate_new_index_name
      __elasticsearch__.create_index!(index:, force: true)
      searchable_log "Created new Opensearch index #{index} for #{name}"
      index
    end

    # Adds the given index to the model alias.
    # The alias name is the 'index_name' declaration in the model.
    def alias_index!(index)
      __elasticsearch__.client.indices.put_alias(index:, name: index_name)
      searchable_log "Pointed Opensearch #{name} index alias to index #{index}"
      true
    end

    # Model index alias stop pointing to from/current index and starts pointing to the "to:" index without downtime.
    def swap_index_alias!(to:, from: current_index)
      indices_client = __elasticsearch__.client.indices

      if indices_client.exists_alias?(name: index_name)
        indices_client.update_aliases body: {
          actions: [
            { remove: { index: from, alias: index_name } },
            { add:    { index: to, alias: index_name } },
          ],
        }
        searchable_log "Swapped Opensearch #{name} index alias #{index_name} from index #{from} to index #{to}"
        true
      else # If the alias does not exist, create it.
        alias_index!(to)
      end
    end

    def current_index
      indices_client = __elasticsearch__.client.indices
      # If there is an index associated to the model alias name
      if indices_client.exists_alias?(name: index_name)
        indices_client.get_alias(name: index_name).keys.first
      # If there is an index created using the index alias name.
      elsif indices_client.exists?(index: index_name)
        index_name
      end
    end

    def previous_indices
      __elasticsearch__.client.indices.get(index: "#{index_name}*").keys.excluding(current_index)
    end

    # Generates a new version of the index name, using the alias name as a base and appending the current datetime.
    # EG: Alias is called "foobar_index", the new index name will be "foobar_index_20221205164343
    def generate_new_index_name
      "#{index_name}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}"
    end

    # Returns the number of documents in the provided/current index.
    def index_docs_count(index = current_index)
      return if index.blank?

      __elasticsearch__.client.count(index:)["count"]
    end

    def searchable_log(msg)
      Rails.logger.info "[#{name}Index] #{msg}"
    end
  end
end
