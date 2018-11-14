class Test::Result < Test

  validates :result, presence: true

  def pretty_name
    "test result"
  end
end
