class Alert < ApplicationRecord
  include Searchable
  include Documentable

  has_one :investigation
end
