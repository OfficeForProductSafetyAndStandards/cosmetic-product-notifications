class Tab
  attr_reader :id, :title, :render, :item_count, :hide_title

  def initialize(id, title, render, item_count = '', hide_title = false)
    @id = id
    @title = title
    @render = render
    @hide_title = hide_title
    @item_count = item_count
  end
end
