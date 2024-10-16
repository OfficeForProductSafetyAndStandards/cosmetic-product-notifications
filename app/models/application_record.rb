class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def update_with_context(attributes, context)
    with_transaction_returning_status do
      assign_attributes(attributes)
      save(context:)
    end
  end
end
