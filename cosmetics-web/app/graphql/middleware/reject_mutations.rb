module Middleware
  class RejectMutations
    def call(parent_type, _parent_object, _field_definition, _field_args, _query_context)
      if parent_type.kind.mutation?
        raise GraphQL::ExecutionError, "Mutations are not allowed in this schema"
      end

      yield
    end
  end
end
