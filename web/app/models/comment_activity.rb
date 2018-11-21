class CommentActivity < Activity
  validates :body, presence: true

  def title
    "Comment: #{source&.show&.titleize}"
  end

  def subtitle
    pretty_date_stamp
  end

  def search_index
    body
  end
end
