class Tab
  attr_reader :id, :title, :render

  def initialize(id, title, partial)
    @id = id
    @title = title
    @render = partial
  end
end
