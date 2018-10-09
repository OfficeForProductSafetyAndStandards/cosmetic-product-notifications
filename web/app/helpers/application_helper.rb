module ApplicationHelper
  class Tab
    attr_reader :id, :title, :partial

    def initialize(id, title, partial)
      @id = id
      @title = title
      @partial = partial
    end
  end

  def tab(id, title, partial)
    Tab.new id, title, partial
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : "unselected"
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, query_params.merge(sort: column, direction: direction), class: "sort-link #{css_class}"
  end
end
