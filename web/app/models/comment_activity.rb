class CommentActivity < Activity
  validates :body, presence: true
end
