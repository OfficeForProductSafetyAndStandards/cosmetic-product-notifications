class Test < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :product

  has_many_attached :documents

  validates :investigation, presence: true
  validates :product, presence: true
  validates :date, presence: true
  validates :legislation, presence: true

  validates_length_of :details, maximum: 1000

  def initialize(*args)
    raise "Cannot directly instantiate a Test record" if self.class == Test

    super
  end

  def pretty_name; end

  def requested?; end
end
