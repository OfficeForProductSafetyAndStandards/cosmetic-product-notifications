module Types
  class VersionOrderByInputType < BaseInputObject
    description "Options to sort version records"

    argument :field, String, required: false,
                             description: "Which field to sort by (e.g. 'created_at', 'item_type')"
    argument :direction, String, required: false,
                                 description: "Sort direction ('asc' or 'desc')"
  end
end
