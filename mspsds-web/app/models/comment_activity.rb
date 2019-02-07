class CommentActivity < Activity
  validates :body, presence: true
  validates_length_of :body, maximum: 1000

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
    "#{source&.show&.titleize} commented on the #{investigation.case_type}"
  end
end
