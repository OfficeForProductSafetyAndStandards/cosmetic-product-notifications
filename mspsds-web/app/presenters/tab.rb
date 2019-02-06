class Tab
  attr_reader :id, :title, :render

  def initialize(id, title, render)
    @id = id
    @title = title
    @render = render
  end

  def hide_title
    if @title == "Overview"
      true
    else
      false
    end
  end
end
