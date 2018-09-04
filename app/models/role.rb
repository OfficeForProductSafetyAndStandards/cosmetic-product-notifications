class Role < ApplicationRecord
  # This is built into the Rolify library, so we can't change it here
  has_and_belongs_to_many :users, join_table: :users_roles


  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify
end
