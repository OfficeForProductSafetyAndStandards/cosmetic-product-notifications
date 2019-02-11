class Tab
  attr_reader :id, :title, :render, :hide_title

  def initialize(id, title, render, hide_title = false)
    @id = id
    @title = title
    @render = render
    @hide_title = hide_title
  end
end
