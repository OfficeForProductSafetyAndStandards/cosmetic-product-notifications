class ApiKey < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :team, presence: true

  def self.create_with_generated_key(team:)
    api_key = new(team:)
    api_key.key = SecureRandom.hex(32)
    api_key.save!
    api_key
  end
end
