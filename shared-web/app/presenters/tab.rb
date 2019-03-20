class Tab
  attr_reader :id, :title, :header, :render

  def initialize(id, title, header, render)
    @id = id
    @title = title
    @header = header
    @render = render
  end
end
