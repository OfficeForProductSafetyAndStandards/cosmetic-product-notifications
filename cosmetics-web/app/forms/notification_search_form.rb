class NotificationSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend CategoryHelper

  CATEGORIES = get_main_categories.map { |c| get_category_name(c) }

  attribute :q
  attribute :category
end
