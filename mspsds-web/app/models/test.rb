class Test < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :product

  has_many_attached :documents

  before_validation :trim_end_line
  validates :legislation, presence: { message: "Select the legislation that relates to this test" }
  validates_length_of :details, maximum: 50000

  def initialize(*args)
    raise "Cannot directly instantiate a Test record" if self.class == Test

    super
  end

  def pretty_name; end

  def requested?; end

private

  # Browsers treat end of line as one character when checking input length, but send it as \r\n, 2 characters
  # To keep max length consistent we need to reverse that
  def trim_end_line
    self.details.gsub!("\r\n", "\n") if self.details
  end
end
