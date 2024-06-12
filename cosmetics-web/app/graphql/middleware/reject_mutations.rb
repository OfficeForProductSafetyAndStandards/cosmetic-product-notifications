module Middleware
  class RejectMutations
    def call(parent_type, parent_object, field_definition, field_args, query_context)
      if parent_type.kind.mutation?
        raise GraphQL::ExecutionError, "Mutations are not allowed in this schema"
      end
      yield
    end
  end
end
