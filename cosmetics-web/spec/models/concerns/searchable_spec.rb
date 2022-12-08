require "rails_helper"

RSpec.describe Searchable, type: :model do
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include Searchable

      index_name "dummies"

      def self.name = "DummyClass"
    end
  end

  after do
    # Ensure no testing indices are left behind
    existing_indices = Elasticsearch::Model.client.indices.get(index: "dummies*").keys.join(",")
    if existing_indices.present?
      Elasticsearch::Model.client.indices.delete(index: existing_indices, ignore_unavailable: true)
    end
  end

  describe ".import_to_opensearch" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:new_index_name) { "dummies_20221201131045" }

    let(:previous_execution_time) { Time.zone.local(2020, 11, 28, 14, 11, 55) }
    let(:previous_index_name) { "dummies_20201128141155" }

    before do
      # ES '.import' needs an AR class to be called. Hence the stubbing.
      allow(dummy_class).to receive(:import).with(any_args).and_return(0)
    end

    context "with forced creation" do
      subject(:import) { dummy_class.import_to_opensearch(force: true) }

      it "creates a new index" do
        travel_to execution_time do
          import
          expect(dummy_class.__elasticsearch__.client.indices.exists?(index: new_index_name)).to be true
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it "deletes the previous index associated with the model alias" do
        travel_to previous_execution_time do
          dummy_class.create_new_index_with_alias! # Previous index gets created/aliased
        end
        travel_to execution_time do
          expect { import }.to change {
            dummy_class.__elasticsearch__.client.indices.exists?(index: previous_index_name)
          }.from(true).to(false)
        end
      end
      # rubocop:enable RSpec/ExampleLength

      it "imports the records to the new index" do
        travel_to execution_time do
          import
          expect(dummy_class).to have_received(:import)
                             .with(index: new_index_name, scope: "opensearch", refresh: true)
        end
      end
    end

    context "without forced creation" do
      subject(:import) { dummy_class.import_to_opensearch(force: false) }

      context "when there was a previous index" do
        before do
          travel_to previous_execution_time do
            dummy_class.create_new_index_with_alias!
          end
        end

        it "does not create a new index" do
          travel_to execution_time do
            import
            expect(dummy_class.__elasticsearch__.client.indices.exists?(index: new_index_name)).to be false
          end
        end

        it "does not delete the previous index associated with the model alias" do
          travel_to execution_time do
            expect { import }.not_to change {
              dummy_class.__elasticsearch__.client.indices.exists?(index: previous_index_name)
            }.from(true)
          end
        end

        it "imports the records to the current index" do
          travel_to execution_time do
            import
            expect(dummy_class).to have_received(:import)
                               .with(index: previous_index_name, scope: "opensearch", refresh: true)
          end
        end
      end

      context "when there was no previous index" do
        it "creates a new index" do
          travel_to execution_time do
            import
            expect(dummy_class.__elasticsearch__.client.indices.exists?(index: new_index_name)).to be true
          end
        end

        it "imports the records to the new index" do
          travel_to execution_time do
            import
            expect(dummy_class).to have_received(:import)
                               .with(index: new_index_name, scope: "opensearch", refresh: true)
          end
        end
      end
    end
  end

  describe ".generate_new_index_name" do
    it "generates a timestamped version of the index name based on the index_name alias and the current time" do
      travel_to Time.zone.local(2022, 12, 1, 13, 10, 45) do
        expect(dummy_class.generate_new_index_name).to eq "dummies_20221201131045"
      end
    end

    context "when the class does not have an explicit index_name definition" do
      let(:dummy_class) do
        Class.new do
          include ActiveModel::Model
          include Searchable

          def self.name = "DummyClass"
        end
      end

      it "defaults to inferred index_name" do
        travel_to Time.zone.local(2022, 12, 1, 13, 10, 45) do
          expect(dummy_class.generate_new_index_name).to eq "dummy_classes_20221201131045"
        end
      end
    end
  end

  describe ".current_index_name" do
    let(:alias_name) { dummy_class.index_name }
    let(:stubbed_aliases_list) do
      { "dummies_20221205184133" => { "aliases" => { alias_name => {} } } }
    end
    let(:stubbed_indices_client) do
      instance_double(Elasticsearch::API::Indices::IndicesClient,
                      exists_alias?: true,
                      get_alias: stubbed_aliases_list)
    end

    before do
      allow(dummy_class).to receive_message_chain(:__elasticsearch__, :client, :indices).and_return(stubbed_indices_client)
      allow(dummy_class).to receive(:index_name).and_return(alias_name)
    end

    it "returns the current index associated with the model alias" do
      expect(dummy_class.current_index_name).to eq "dummies_20221205184133"
    end

    context "when there is no existing alias" do
      before do
        allow(stubbed_indices_client).to receive(:exists_alias?).with(name: alias_name).and_return(false)
      end

      it "returns the model alias name if there is an index named after it" do
        allow(stubbed_indices_client).to receive(:exists?).with(index: alias_name).and_return(true)
        expect(dummy_class.current_index_name).to eq alias_name
      end

      it "returns nil if there is no index named after the model alias name" do
        allow(stubbed_indices_client).to receive(:exists?).with(index: alias_name).and_return(false)
        expect(dummy_class.current_index_name).to be_nil
      end
    end
  end

  describe ".create_new_index_with_alias!" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:expected_index) { "dummies_20221201131045" }

    before { travel_to execution_time }

    it "creates a new index with a timestamped name" do
      dummy_class.create_new_index_with_alias!
      expect(dummy_class.__elasticsearch__.client.indices.exists?(index: expected_index)).to be true
    end

    it "sets the model alias pointing to the index" do
      dummy_class.create_new_index_with_alias!
      expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)).to eq(
        { expected_index => { "aliases" => { "dummies" => {} } } },
      )
    end
  end

  describe ".create_new_index!" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:expected_index) { "dummies_20221201131045" }

    before { travel_to execution_time }

    it "creates a new index with a timestamped name" do
      dummy_class.create_new_index!
      expect(dummy_class.__elasticsearch__.client.indices.exists?(index: expected_index)).to be true
    end

    it "returns the new index name" do
      expect(dummy_class.create_new_index!).to eq expected_index
    end
  end

  describe ".alias_index!" do
    it "associates the given index index with the model alias" do
      dummy_class.__elasticsearch__.create_index!(index: "dummies_version")
      dummy_class.alias_index!("dummies_version")
      expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)).to eq(
        { "dummies_version" => { "aliases" => { "dummies" => {} } } },
      )
    end

    it "raises an error if the given index does not exist" do
      expect { dummy_class.alias_index!("dummies_version") }
        .to raise_error Elasticsearch::Transport::Transport::Errors::NotFound
    end
  end

  describe ".index_docs_count" do
    let(:count_response) { { "count" => 61, "_shards" => { "total" => 1, "successful" => 1, "skipped" => 0, "failed" => 0 } } }
    let(:client) { instance_double(Elasticsearch::Client, count: count_response) }

    before do
      allow(dummy_class).to receive_message_chain(:__elasticsearch__, :client).and_return(client)
    end

    it "returns the number of documents listed in the given index" do
      expect(dummy_class.index_docs_count("dummies_20221205184133")).to eq 61
      expect(client).to have_received(:count).with(index: "dummies_20221205184133")
    end

    context "when no index is provided" do
      it "returns the number of documents in the current index associated with the model" do
        allow(dummy_class).to receive(:current_index_name).and_return("dummies_20221205184133")
        expect(dummy_class.index_docs_count).to eq 61
        expect(client).to have_received(:count).with(index: "dummies_20221205184133")
      end

      it "returns nil if there is no index associated with the model" do
        allow(dummy_class).to receive(:current_index_name).and_return(nil)
        expect(dummy_class.index_docs_count).to eq nil
        expect(client).not_to have_received(:count)
      end
    end
  end

  describe "swap_index_alias!" do
    let!(:current_index) do
      travel_to Time.zone.local(2022, 12, 1, 13, 10, 45)
      dummy_class.create_new_index_with_alias!
    end

    let!(:new_index) do
      travel_to Time.zone.local(2022, 12, 2, 10, 12, 30)
      dummy_class.create_new_index!
    end

    it "removes one index from the model alias and adds the other" do
      expect { dummy_class.swap_index_alias!(from: current_index, to: new_index) }.to change {
        dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)
      }.from({ current_index => { "aliases" => { "dummies" => {} } } })
       .to({ new_index => { "aliases" => { "dummies" => {} } } })
    end

    it "defaults to the current index when not 'from' index is given" do
      expect { dummy_class.swap_index_alias!(to: new_index) }.to change {
        dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)
      }.from({ current_index => { "aliases" => { "dummies" => {} } } })
       .to({ new_index => { "aliases" => { "dummies" => {} } } })
    end
  end
end
