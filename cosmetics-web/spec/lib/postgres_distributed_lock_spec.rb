require "rails_helper"

RSpec.describe PostgresDistributedLock do
  describe ".try_with_lock" do
    let(:pg_connection_stub) { instance_double(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) }

    before do
      allow(pg_connection_stub).to receive(:transaction).and_yield
      allow(ActiveRecord::Base).to receive(:connection).and_return(pg_connection_stub)
    end

    it "executes the given code when can acquire the lock" do
      allow(pg_connection_stub).to receive(:select_value).and_return(true)
      expect { |b| described_class.try_with_lock("test_lock", &b) }.to yield_control.once
    end

    it "does not execute the given code when cannot acquire the lock" do
      allow(pg_connection_stub).to receive(:select_value).and_return(false)
      expect { |b| described_class.try_with_lock("test_lock", &b) }.not_to yield_control
    end
  end
end
