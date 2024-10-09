module Errors
  class SimpleError < GraphQL::ExecutionError
    def to_h
      { "message" => message }
    end
  end
end
