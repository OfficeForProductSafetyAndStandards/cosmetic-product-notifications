class Test < ApplicationRecord
  include Shared::Web::Concerns::DateConcern
  include SanitizationHelper

  belongs_to :investigation
  belongs_to :product

  has_many_attached :documents

  date_attribute :date

  before_validation { trim_line_endings(:details) }
  validates :legislation, presence: { message: "Select the legislation that relates to this test" }
  validates_length_of :details, maximum: 50000

  def initialize(*args)
    raise "Cannot directly instantiate a Test record" if self.class == Test

    super
  end

  def pretty_name; end

  def requested?; end
end
