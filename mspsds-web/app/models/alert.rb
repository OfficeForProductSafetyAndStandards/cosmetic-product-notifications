class Alert < ApplicationRecord
  include Searchable
  include Documentable

  belongs_to :investigation

  validates :summary, presence: true
end
