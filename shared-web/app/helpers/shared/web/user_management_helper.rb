module Shared
  module Web
    module UserManagementHelper
      def user_account_url
        ::KeycloakClient.instance.user_account_url
      end
    end
  end
end
