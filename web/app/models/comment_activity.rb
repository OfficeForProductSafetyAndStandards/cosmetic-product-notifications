class CommentActivity < Activity
  validates :description, presence: true
end
