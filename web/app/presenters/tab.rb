class Tab
  attr_reader :id, :title, :partial

  def initialize(id, title, partial)
    @id = id
    @title = title
    @partial = partial
  end
end
