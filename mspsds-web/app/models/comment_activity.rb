class CommentActivity < Activity
  before_validation :trim_end_line
  validates :body, presence: true
  validates_length_of :body, maximum: 10000

  def title
    "Comment: #{source&.show&.titleize}"
  end

  def subtitle
    pretty_date_stamp
  end

  def search_index
    body
  end

  def email_update_text
    "#{source&.show&.titleize} commented on the #{investigation.case_type}."
  end

private

  # Browsers treat end of line as one character when checking input length, but send it as \r\n, 2 characters
  # To keep max length consistent we need to reverse that
  def trim_end_line
    self.body.gsub!("\r\n", "\n") if self.body
  end
end
