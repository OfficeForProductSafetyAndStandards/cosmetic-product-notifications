class Tab
  attr_reader :id, :title, :render

  def initialize(id, title, render)
    @id = id
    @title = title
    @render = render
  end

  def hide_title
    @title == "Overview"
  end
end
