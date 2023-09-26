# Each access method that depends on the user type, should be declared in this helper.
# Despite the fact, that the some of the roles are used only in search part of the service,
# it is easier to have a single place with all roles defined.
#
# All methods have to correspond with methods defined in `Privileges::AbstractConcern` concern.
module PrivilegesHelper
  delegate :can_view_product_ingredients?, to: :current_user

  delegate :can_view_ingredients_list?, to: :current_user

  delegate :can_search_for_ingredients?, to: :current_user

  delegate :can_view_nanomaterial_notification_files?, to: :current_user

  delegate :can_view_nanomaterial_review_period_end_date?, to: :current_user

  delegate :can_view_responsible_person_address_history?, to: :current_user

  delegate :can_view_notification_history?, to: :current_user
end
