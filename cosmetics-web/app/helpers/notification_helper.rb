module NotificationHelper
  def search_date_filter_input(form_builder, field, foo)
    render partial: 'date_filter_input', locals: { form: form_builder, field: field }
  end
end
