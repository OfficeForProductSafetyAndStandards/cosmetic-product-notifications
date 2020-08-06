module Users
  class UnlocksController < Devise::UnlocksController
    skip_before_action :require_no_authentication,
                       :has_accepted_declaration,
                       :create_or_join_responsible_person,
                       only: :show

    def show
      super
    rescue ActiveRecord::RecordNotFound
      render "invalid_link", status: :not_found
    end

  private

    def passed_secondary_authentication?
      return true unless Rails.configuration.secondary_authentication_enabled

      user_signed_in? && user_with_unlock_token == current_user && is_fully_authenticated?
    end

    def user_with_unlock_token
      @user_with_unlock_token ||= begin
        unlock_token = Devise.token_generator.digest(self, :unlock_token, params[:unlock_token])

        User.find_by!(unlock_token: unlock_token)
      end
    end

    def user_id_for_secondary_authentication
      user_with_unlock_token.id
    rescue ActiveRecord::RecordNotFound
      render "invalid_link", status: :not_found
      nil
    end

    def current_operation
      SecondaryAuthentication::UNLOCK_OPERATION
    end
  end
end
