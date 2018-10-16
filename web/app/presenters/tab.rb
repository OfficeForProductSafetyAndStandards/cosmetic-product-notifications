class Tab
  attr_reader :id, :title, :render

  def initialize(id, title, render)
    @id = id
    @title = title
    @render = render
  end
end
