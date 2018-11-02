class CommentActivity < Activity
  validates :body, presence: true

  def subtitle_slug
    "Comment added"
  end
end
