class TeamMember < ApplicationRecord
  belongs_to :responsible_person
  belongs_to :user
end
