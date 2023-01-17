# Each access method that depends on the user type, should be declared in this helper
# Despite the fact, that the some of the roles are used only in search part of the service,
# it is easier to have single place with all roles definded.
#
# All roles have to correspond with roles defined in `Privileges::AbstractConcern` concern.
module RolesHelper
  delegate :can_view_product_ingredients?, to: :current_user

  delegate :can_view_nanomaterial_notification_files?, to: :current_user

  delegate :can_view_nanomaterial_review_period_end_date?, to: :current_user
end
