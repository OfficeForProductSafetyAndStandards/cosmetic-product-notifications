module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : "unselected"
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, query_params.merge(sort: column, direction: direction), class: "sort-link #{css_class}"
  end

  def markdown(text)
    rc = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    sanitized_input = sanitize(text, tags: %w(br))
    rc.render(sanitized_input).html_safe
  end
end
