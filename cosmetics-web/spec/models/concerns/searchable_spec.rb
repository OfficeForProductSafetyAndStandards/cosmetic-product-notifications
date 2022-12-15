require "rails_helper"

RSpec.describe Searchable, type: :model do
  let(:dummy_class) do
    Class.new do
      include ActiveModel::Model
      include Searchable

      def self.index_name = "dummies"
      def self.name = "DummyClass"
    end
  end

  before do
    allow(Rails.logger).to receive(:info)
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
      allow(dummy_class.__elasticsearch__.client).to receive(:count).with(any_args).and_return({ "count" => 25 })
    end

    RSpec.shared_examples "creating a new index" do
      it "creates a new index" do
        travel_to execution_time
        expect { import }.to change {
          dummy_class.__elasticsearch__.client.indices.exists?(index: new_index_name)
        }.from(false).to(true)
      end

      it "logs the index creation" do
        travel_to execution_time
        import
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Created new Opensearch index #{new_index_name} for DummyClass")
      end

      it "sets the model alias pointing to the index" do
        travel_to execution_time
        import
        expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)).to eq(
          { new_index_name => { "aliases" => { "dummies" => {} } } },
        )
      end

      it "logs the alias creation" do
        travel_to execution_time
        import
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Pointed Opensearch DummyClass index alias to index #{new_index_name}")
      end
    end

    RSpec.shared_examples "deleting previous index" do
      it "deletes the previous index associated with the model alias" do
        travel_to execution_time
        expect { import }.to change {
          dummy_class.__elasticsearch__.client.indices.exists?(index: previous_index_name)
        }.from(true).to(false)
      end

      it "logs the previous index deletion" do
        travel_to execution_time
        import
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Deleted Opensearch indices #{previous_index_name} for DummyClass")
      end
    end

    RSpec.shared_examples "importing notifications" do
      it "imports the records to index" do
        travel_to execution_time
        import
        expect(dummy_class).to have_received(:import).with(index:, scope: "opensearch", refresh: true)
      end

      context "when importing without errors" do
        it "logs the number of records imported" do
          travel_to execution_time
          import
          expect(Rails.logger)
            .to have_received(:info)
            .with("[DummyClassIndex] Imported 25 records for DummyClass to Opensearch #{index} index")
        end

        it "returns the number of errors found during the import" do
          travel_to execution_time
          expect(import).to eq(0)
        end
      end

      context "when importing with errors" do
        before do
          allow(dummy_class).to receive(:import).with(any_args).and_return(3)
        end

        it "logs the number of errors encountered during import" do
          travel_to execution_time
          import
          expect(Rails.logger)
            .to have_received(:info)
            .with("[DummyClassIndex] Got 3 errors while importing DummyClass records to Opensearch #{index} index")
        end

        it "returns the number of errors found during the import" do
          travel_to execution_time
          expect(import).to eq(3)
        end
      end
    end

    RSpec.shared_examples "keeping current index" do
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
    end

    context "with forced creation" do
      subject(:import) { dummy_class.import_to_opensearch(force: true) }

      include_examples "creating a new index"
      include_examples "importing notifications" do
        let(:index) { new_index_name }
      end

      context "when there is a current index" do
        before do
          travel_to previous_execution_time do
            dummy_class.create_aliased_index! # Previous index gets created/aliased
          end
        end

        context "without an index to import to" do
          include_examples "deleting previous index"
        end

        context "when given an index to import to" do
          subject(:import) { dummy_class.import_to_opensearch(index: other_index, force: true) }

          let!(:other_index) { dummy_class.create_index! }

          include_examples "keeping current index"
          include_examples "importing notifications" do
            let(:index) { other_index }
          end

          it "deletes and creates the given index" do
            travel_to execution_time
            allow(dummy_class.__elasticsearch__).to receive(:create_index!)
            import
            expect(dummy_class.__elasticsearch__).to have_received(:create_index!).with(index: other_index, force: true)
          end
        end
      end
    end

    context "without forced creation" do
      subject(:import) { dummy_class.import_to_opensearch(force: false) }

      context "when there was no previous index" do
        include_examples "creating a new index"
        include_examples "importing notifications" do
          let(:index) { new_index_name }
        end
      end

      context "when there is a current index" do
        before do
          travel_to previous_execution_time do
            dummy_class.create_aliased_index! # current_index gets created/aliased
          end
        end

        context "without an index to import to" do
          include_examples "keeping current index"
          include_examples "importing notifications" do
            let(:index) { previous_index_name }
          end
        end

        context "when given an index to import to" do
          subject(:import) { dummy_class.import_to_opensearch(index: other_index, force: false) }

          let!(:other_index) { dummy_class.create_index! }

          include_examples "keeping current index"
          include_examples "importing notifications" do
            let(:index) { other_index }
          end

          it "does not delete and create the given index" do
            travel_to execution_time
            allow(dummy_class.__elasticsearch__).to receive(:create_index!)
            import
            expect(dummy_class.__elasticsearch__).not_to have_received(:create_index!).with(index: other_index, force: true)
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

  describe ".current_index" do
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
    end

    it "returns the current index associated with the model alias" do
      expect(dummy_class.current_index).to eq "dummies_20221205184133"
    end

    context "when there is no existing alias" do
      before do
        allow(stubbed_indices_client).to receive(:exists_alias?).with(name: alias_name).and_return(false)
      end

      it "returns the model alias name if there is an index named after it" do
        allow(stubbed_indices_client).to receive(:exists?).with(index: alias_name).and_return(true)
        expect(dummy_class.current_index).to eq alias_name
      end

      it "returns nil if there is no index named after the model alias name" do
        allow(stubbed_indices_client).to receive(:exists?).with(index: alias_name).and_return(false)
        expect(dummy_class.current_index).to be_nil
      end
    end
  end

  describe ".unused_indices" do
    let(:current_index) { "dummies_20221205184135" }
    let(:all_indices) do
      {
        "dummies_20221002184133" => {},
        "dummies_20221105184134" => {},
        current_index => {},
        "dummies_20221215093011" => {}, # Index created later but not aliased as current
      }
    end
    let(:stubbed_client) do
      instance_double(Elasticsearch::API::Indices::IndicesClient, get: all_indices)
    end

    before do
      allow(dummy_class).to receive_message_chain(:__elasticsearch__, :client, :indices).and_return(stubbed_client)
      allow(dummy_class).to receive(:current_index).and_return(current_index)
    end

    it "returns all the indices named after the alias except the current one" do
      expect(dummy_class.unused_indices).to eq %w[dummies_20221002184133 dummies_20221105184134 dummies_20221215093011]
    end

    context "when there are no other indices besides the current one" do
      let(:all_indices) do
        { current_index => {} }
      end

      it "returns an empty array" do
        expect(dummy_class.unused_indices).to eq []
      end
    end
  end

  describe ".create_aliased_index!" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:expected_index) { "dummies_20221201131045" }

    before { travel_to execution_time }

    it "creates a new index with a timestamped name" do
      dummy_class.create_aliased_index!
      expect(dummy_class.__elasticsearch__.client.indices.exists?(index: expected_index)).to be true
    end

    it "sets the model alias pointing to the index" do
      dummy_class.create_aliased_index!
      expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)).to eq(
        { expected_index => { "aliases" => { "dummies" => {} } } },
      )
    end
  end

  describe ".create_index!" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:expected_index) { "dummies_20221201131045" }

    before { travel_to execution_time }

    it "creates a new index with a timestamped name" do
      dummy_class.create_index!
      expect(dummy_class.__elasticsearch__.client.indices.exists?(index: expected_index)).to be true
    end

    it "logs the index creation" do
      dummy_class.create_index!
      expect(Rails.logger)
        .to have_received(:info)
        .with("[DummyClassIndex] Created new Opensearch index #{expected_index} for DummyClass")
    end

    it "returns the new index name" do
      expect(dummy_class.create_index!).to eq expected_index
    end
  end

  describe ".delete_indices!" do
    let(:indices) { "dummies_20221205184133,dummies_20222206123007" }

    before do
      allow(dummy_class.__elasticsearch__).to receive(:delete_index!).and_return({ "acknowledged" => true })
    end

    it "deletes the given indices" do
      dummy_class.delete_indices!(indices)
      expect(dummy_class.__elasticsearch__).to have_received(:delete_index!).with(index: indices)
    end

    it "logs the index deletion" do
      dummy_class.delete_indices!(indices)
      expect(Rails.logger)
        .to have_received(:info)
        .with("[DummyClassIndex] Deleted Opensearch indices #{indices} for DummyClass")
    end

    it { expect(dummy_class.delete_indices!(indices)).to eq true }
  end

  describe ".alias_index!" do
    context "when given an existing index" do
      before do
        dummy_class.__elasticsearch__.create_index!(index: "dummies_version")
      end

      it "associates the given index index with the model alias" do
        dummy_class.alias_index!("dummies_version")
        expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name)).to eq(
          { "dummies_version" => { "aliases" => { "dummies" => {} } } },
        )
      end

      it "logs the index aliasing" do
        dummy_class.alias_index!("dummies_version")
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Pointed Opensearch DummyClass index alias to index dummies_version")
      end

      it { expect(dummy_class.alias_index!("dummies_version")).to eq true }
    end

    context "when given a non existing index" do
      it "raises an error" do
        expect { dummy_class.alias_index!("dummies_version") }
          .to raise_error Elasticsearch::Transport::Transport::Errors::NotFound
      end
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
        allow(dummy_class).to receive(:current_index).and_return("dummies_20221205184133")
        expect(dummy_class.index_docs_count).to eq 61
        expect(client).to have_received(:count).with(index: "dummies_20221205184133")
      end

      it "returns nil if there is no index associated with the model" do
        allow(dummy_class).to receive(:current_index).and_return(nil)
        expect(dummy_class.index_docs_count).to eq nil
        expect(client).not_to have_received(:count)
      end
    end
  end

  describe "swap_index_alias!" do
    let!(:new_index) do
      travel_to Time.zone.local(2022, 12, 2, 10, 12, 30)
      dummy_class.create_index!
    end

    context "when the alias already exists and points to the current index" do
      let!(:current_index) do
        travel_to Time.zone.local(2022, 12, 1, 13, 10, 45)
        dummy_class.create_aliased_index!
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

      it "logs the index alias swapping between indices" do
        dummy_class.swap_index_alias!(from: current_index, to: new_index)
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Swapped Opensearch DummyClass index alias dummies from index #{current_index} to index #{new_index}")
      end

      it { expect(dummy_class.swap_index_alias!(from: current_index, to: new_index)).to eq true }
    end

    context "when there is no existing alias pointing to the current index" do
      let(:current_index) do
        travel_to Time.zone.local(2022, 12, 1, 13, 10, 45)
        dummy_class.create_index!
      end

      it "adds the new index to the model alias" do
        dummy_class.swap_index_alias!(from: current_index, to: new_index)
        expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name))
          .to eq({ new_index => { "aliases" => { "dummies" => {} } } })
      end

      it "logs the index alias setting" do
        dummy_class.swap_index_alias!(from: current_index, to: new_index)
        expect(Rails.logger)
          .to have_received(:info)
          .with("[DummyClassIndex] Pointed Opensearch DummyClass index alias to index #{new_index}")
      end

      it { expect(dummy_class.swap_index_alias!(from: current_index, to: new_index)).to eq true }
    end

    context "when there is no other index or alias" do
      it "adds the new index to the model alias" do
        dummy_class.swap_index_alias!(from: nil, to: new_index)
        expect(dummy_class.__elasticsearch__.client.indices.get_alias(name: dummy_class.index_name))
          .to eq({ new_index => { "aliases" => { "dummies" => {} } } })
      end

      it { expect(dummy_class.swap_index_alias!(from: nil, to: new_index)).to eq true }
    end
  end
end
