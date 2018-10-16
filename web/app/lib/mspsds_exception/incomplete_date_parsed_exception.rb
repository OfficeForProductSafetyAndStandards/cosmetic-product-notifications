module MspsdsException
  class IncompleteDateParsedException < RuntimeError
    attr_accessor :missing_fields

    def initialize(missing_fields)
      @missing_fields = missing_fields
    end
  end
end
