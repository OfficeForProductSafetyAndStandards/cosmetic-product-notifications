# Foo
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def update_with_context(attributes, context)
    with_transaction_returning_status do
      assign_attributes(attributes)
      save(context:)
    end
  end
end
