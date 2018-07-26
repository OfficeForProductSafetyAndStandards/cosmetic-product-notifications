class KeycloakUser
    def initialize()
        userinfo = JSON(Keycloak::Client.get_userinfo)
        @email = userinfo[:email]
    end

    def has_role?(role)
        Keycloak::Client.has_role? role
    end
end
