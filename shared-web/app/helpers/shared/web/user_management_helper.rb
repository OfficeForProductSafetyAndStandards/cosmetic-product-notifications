module Shared
  module Web
    module UserManagementHelper
      def user_account_url
        Shared::Web::KeycloakClient.instance.user_account_url
      end

      def user_group_ids
        [current_user.id]
      end
    end
  end
end
