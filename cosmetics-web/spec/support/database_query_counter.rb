module DatabaseQueryCounter
  def make_database_queries(count: nil, matching: nil, includes: nil, exact: nil)
    QueryCounter.new(count: count, matching: matching, includes: includes, exact: exact)
  end

  class QueryCounter
    def initialize(count: nil, matching: nil, includes: nil, exact: nil)
      @count = count
      @matching = matching
      @includes = includes
      @exact = exact
      @queries = []
    end

    def matches?(event_proc)
      @queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
        @queries << payload[:sql] unless payload[:name] == "SCHEMA" || payload[:sql].match?(/\A\s*BEGIN|\A\s*COMMIT|\A\s*ROLLBACK/)
      end

      event_proc.call
      ActiveSupport::Notifications.unsubscribe(subscriber)

      return matches_count?(@queries) if @count
      return matches_exact?(@queries) if @exact
      return matches_includes?(@queries) if @includes
      return matches_matching?(@queries) if @matching

      true
    end

    def failure_message
      "expected database queries to match #{expectation}, but got #{@queries.length} queries:\n#{@queries.join("\n")}"
    end

    def supports_block_expectations?
      true
    end

  private

    def matches_count?(queries)
      case @count
      when Range
        @count.include?(queries.length)
      when Integer
        queries.length == @count
      else
        queries.length == @count
      end
    end

    def matches_exact?(queries)
      queries == Array(@exact)
    end

    def matches_includes?(queries)
      Array(@includes).all? { |included| queries.any? { |q| q.include?(included) } }
    end

    def matches_matching?(queries)
      Array(@matching).all? { |pattern| queries.any? { |q| q.match?(pattern) } }
    end

    def expectation
      return "count #{@count}" if @count
      return "exact #{@exact}" if @exact
      return "includes #{@includes}" if @includes
      return "matching #{@matching}" if @matching

      "unknown expectation"
    end
  end
end
