class Test < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :product

  enum result: { passed: "Pass", failed: "Fail" }

  has_many_attached :documents

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

  def initialize(*args)
    raise "Cannot directly instantiate a Test record" if self.class == Test
    super
  end

  def pretty_name
    "test record"
  end

  def requested?
    self.class == Test::Request
  end
end
